import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/main.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/models/DriverPosition.dart';
import 'package:rabbit_flutter/src/domain/models/StatusTrip.dart';
import 'package:rabbit_flutter/src/domain/models/TimeAndDistanceValues.dart'
    hide Duration;
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripState.dart';
import 'package:rabbit_flutter/src/presentation/utils/CalculateRotation.dart';

class DriverMapTripBloc extends Bloc<DriverMapTripEvent, DriverMapTripState> {
  Timer? timer;
  BlocSocketIO blocSocketIO;
  StreamSubscription? positionSubscription;
  bool _isClosed = false;
  ClientRequestsUseCases clientRequestsUseCases;
  GeolocatorUseCases geolocatorUseCases;
  DriversPositionUseCases driversPositionUseCases;
  AuthUseCases authUseCases;
  double? _lastLat;
  double? _lastLng;
  String? _activePolylineId;

  void _startOrRefreshEtaTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_isClosed || state.position == null) return;
      add(GetTimeAndDistanceValues());
    });
  }

  ({double lat, double lng}) _routeTarget() {
    final request = state.clientRequestResponse;
    if (request == null) {
      return (lat: state.position?.latitude ?? 0, lng: state.position?.longitude ?? 0);
    }
    final toDestination = state.statusTrip == StatusTrip.ARRIVED;
    return (
      lat: toDestination
          ? request.destinationPosition.x
          : request.pickupPosition.x,
      lng: toDestination
          ? request.destinationPosition.y
          : request.pickupPosition.y,
    );
  }

  DriverMapTripBloc(this.blocSocketIO, this.clientRequestsUseCases,
      this.geolocatorUseCases, this.driversPositionUseCases, this.authUseCases)
      : super(DriverMapTripState()) {
    on<InitDriverMapTripEvent>((event, emit) async {
      Completer<GoogleMapController> controller =
          Completer<GoogleMapController>();
      emit(state.copyWith(
        controller: controller,
      ));
    });

    on<AddMarkerPickup>((event, emit) async {
      final pickUpDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/img/person_location.png',
      );
      Marker markerPickUp = geolocatorUseCases.getMarker.run(
          'pickup',
          event.lat,
          event.lng,
          'Lugar de recogida',
          'Debes permancer aqui mientras llega el conductor',
          pickUpDescriptor);
      emit(state.copyWith(
          markers: Map.of(state.markers)
            ..[markerPickUp.markerId] = markerPickUp));
    });

    on<AddMarkerDestination>((event, emit) async {
      BitmapDescriptor destinationDescriptor =
          await geolocatorUseCases.createMarker.run('assets/img/red-flag.png');
      Marker marker = geolocatorUseCases.getMarker.run('destination', event.lat,
          event.lng, 'Lugar de destino', '', destinationDescriptor);
      emit(state.copyWith(
          markers: Map.of(state.markers)..[marker.markerId] = marker));
    });

    on<GetClientRequest>((event, emit) async {
      Resource response = await clientRequestsUseCases.getByClientRequest
          .run(event.idClientRequest);
      emit(state.copyWith(responseGetClientRequest: response));
      if (response is Success) {
        final data = response.data as ClientRequestResponse;
        emit(state.copyWith(clientRequestResponse: data));
        add(FindPosition());
        add(AddMarkerPickup(
            lat: data.pickupPosition.x, lng: data.pickupPosition.y));
      }
    });

    on<GetTimeAndDistanceValues>((event, emit) async {
      final request = state.clientRequestResponse;
      final position = state.position;
      if (request == null || position == null) return;

      final target = _routeTarget();
      final response = await clientRequestsUseCases.getTimeAndDistance.run(
        position.latitude,
        position.longitude,
        target.lat,
        target.lng,
      );
      if (response is Success<TimeAndDistanceValues>) {
        emit(state.copyWith(timeAndDistanceValues: response.data));
      }
    });

    on<SetClientRequestData>((event, emit) async {
      final data = event.clientRequest;
      emit(state.copyWith(
        responseGetClientRequest: Success(data),
        clientRequestResponse: data,
      ));
      add(FindPosition());
      add(AddMarkerPickup(
          lat: data.pickupPosition.x, lng: data.pickupPosition.y));
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      try {
        if (_isClosed || state.controller == null) return;
        GoogleMapController googleMapController =
            await state.controller!.future;
        if (_isClosed) return;
        await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(event.lat, event.lng), zoom: 14, bearing: 0)));
      } catch (e) {
        print('ChangeMapCameraPosition: $e');
      }
    });

    on<AddPolyline>((event, emit) async {
      if (state.clientRequestResponse == null) return;
      List<LatLng> polylineCoordinates =
          await geolocatorUseCases.getPolyline.run(
        LatLng(event.originLat, event.originLng),
        LatLng(event.destinationLat, event.destinationLng),
      );
      if (polylineCoordinates.isEmpty) {
        polylineCoordinates = [
          LatLng(event.originLat, event.originLng),
          LatLng(event.destinationLat, event.destinationLng),
        ];
      }
      PolylineId id = PolylineId(event.idPolyline);
      Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.orange,
          points: polylineCoordinates,
          width: 8);
      _activePolylineId = event.idPolyline;
      emit(state.copyWith(
        polylines: Map.of(state.polylines)..[id] = polyline,
      ));
    });

    on<UpdatePolyline>((event, emit) {
      final polylineId = _activePolylineId ?? 'pickup_polyline';
      final id = PolylineId(polylineId);
      final polyline = state.polylines[id];
      if (polyline == null) return;

      final updatedPoints = List<LatLng>.from(polyline.points);
      final index = updatedPoints.indexWhere(
          (point) => distanceBetween(event.driverPosition, point) < 25);
      if (index != -1) {
        updatedPoints.removeRange(0, index + 1);
      }
      if (updatedPoints.isEmpty) return;

      emit(state.copyWith(polylines: {
        id: polyline.copyWith(pointsParam: updatedPoints),
      }));
    });

    on<FindPosition>((event, emit) async {
      positionSubscription?.cancel();
      geolocator.Position position;
      try {
        position = await geolocatorUseCases.findPosition.run();
      } catch (e) {
        print('DriverMapTrip FindPosition error: $e');
        return;
      }
      add(ChangeMapCameraPosition(
          lat: position.latitude, lng: position.longitude));
      add(AddMyPositionMarker(lat: position.latitude, lng: position.longitude));
      Stream<geolocator.Position> positionStream =
          geolocatorUseCases.getPositionStream.run();
      positionSubscription = positionStream.listen((currentPosition) {
        if (!_isClosed) {
          add(UpdateLocation(position: currentPosition));
        }
      });
      emit(state.copyWith(
        position: position,
        cameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        ),
      ));
      add(GetTimeAndDistanceValues());
      _startOrRefreshEtaTimer();

      final request = state.clientRequestResponse;
      final idDriver = (await authUseCases.getUserSession.run()).user.id;
      if (idDriver != null && idDriver > 0) {
        await driversPositionUseCases.createDriverPosition.run(DriverPosition(
          idDriver: idDriver,
          lat: position.latitude,
          lng: position.longitude,
        ));
      }
      if (request != null) {
        add(EmitDriverPositionSocketIO(
          lat: position.latitude,
          lng: position.longitude,
          idClient: request.idClient,
          idClientRequest: request.id,
        ));
        add(AddPolyline(
          idPolyline: 'pickup_polyline',
          originLat: position.latitude,
          originLng: position.longitude,
          destinationLat: request.pickupPosition.x,
          destinationLng: request.pickupPosition.y,
        ));
      }
    });

    on<AddMyPositionMarker>((event, emit) async {
      final descriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(36, 36)),
        'assets/img/moto_pin.png',
      );
      Marker marker = geolocatorUseCases.getMarker.run(
          'my_location', event.lat, event.lng, 'Mi posicion', '', descriptor);
      emit(state.copyWith(
          markers: Map.of(state.markers)..[marker.markerId] = marker));
    });

    on<RemoveMarker>((event, emit) {
      emit(state.copyWith(
          markers: Map.of(state.markers)..remove(MarkerId(event.idMarker))));
    });

    on<UpdateLocation>((event, emit) async {
      final lat = event.position.latitude;
      final lng = event.position.longitude;
      if (_lastLat != null && _lastLng != null) {
        final moved =
            distanceBetween(LatLng(_lastLat!, _lastLng!), LatLng(lat, lng));
        if (moved < 0.5) return;
      }
      _lastLat = lat;
      _lastLng = lng;

      add(AddMyPositionMarker(lat: lat, lng: lng));
      emit(state.copyWith(position: event.position));

      final idDriver = (await authUseCases.getUserSession.run()).user.id;
      if (idDriver != null && idDriver > 0) {
        await driversPositionUseCases.createDriverPosition.run(DriverPosition(
          idDriver: idDriver,
          lat: lat,
          lng: lng,
        ));
      }

      final request = state.clientRequestResponse;
      if (request != null) {
        final status = state.statusTrip;
        final toDestination = status == StatusTrip.ARRIVED;
        final polylineId =
            toDestination ? 'destination_polyline' : 'pickup_polyline';
        final destinationLat = toDestination
            ? request.destinationPosition.x
            : request.pickupPosition.x;
        final destinationLng = toDestination
            ? request.destinationPosition.y
            : request.pickupPosition.y;
        final activePolyline = state.polylines[PolylineId(polylineId)];

        if (activePolyline == null || _activePolylineId != polylineId) {
          add(AddPolyline(
            idPolyline: polylineId,
            originLat: lat,
            originLng: lng,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
          ));
        } else {
          add(UpdatePolyline(driverPosition: LatLng(lat, lng)));
        }

        add(EmitDriverPositionSocketIO(
          lat: lat,
          lng: lng,
          idClient: request.idClient,
          idClientRequest: request.id,
        ));
        add(GetTimeAndDistanceValues());
      }
    });

    on<StopLocation>((event, emit) {
      positionSubscription?.cancel();
    });

    on<EmitDriverPositionSocketIO>((event, emit) async {
      blocSocketIO.state.socket?.emit('trip_change_driver_position', {
        'id_client': event.idClient,
        if (event.idClientRequest != null)
          'id_client_request': event.idClientRequest,
        'lat': event.lat,
        'lng': event.lng,
      });
    });

    on<EmitUpdateStatusSocketIO>((event, emit) async {
      if (state.clientRequestResponse != null) {
        blocSocketIO.state.socket?.emit('update_status_trip', {
          'id_client_request': state.clientRequestResponse!.id,
          'status': state.statusTrip!.name,
        });
      }
    });

    on<UpdateStatusToArrived>((event, emit) async {
      Resource response = await clientRequestsUseCases.updateStatusClientRequest
          .run(state.clientRequestResponse!.id, StatusTrip.ARRIVED);
      if (response is Success) {
        _activePolylineId = 'destination_polyline';
        emit(state.copyWith(statusTrip: StatusTrip.ARRIVED));
        if (state.position != null) {
          add(AddPolyline(
            idPolyline: "destination_polyline",
            originLat: state.position!.latitude,
            originLng: state.position!.longitude,
            destinationLat: state.clientRequestResponse!.destinationPosition.x,
            destinationLng: state.clientRequestResponse!.destinationPosition.y,
          ));
        }
        add(AddMarkerDestination(
            lat: state.clientRequestResponse!.destinationPosition.x,
            lng: state.clientRequestResponse!.destinationPosition.y));
        add(RemoveMarker(idMarker: 'pickup'));
        add(GetTimeAndDistanceValues());
        _startOrRefreshEtaTimer();
        add(EmitUpdateStatusSocketIO());
      }
    });

    on<UpdateStatusToFinished>((event, emit) async {
      Resource response = await clientRequestsUseCases.updateStatusClientRequest
          .run(state.clientRequestResponse!.id, StatusTrip.FINISHED);
      if (response is Success) {
        timer?.cancel();
        timer = null;
        emit(state.copyWith(statusTrip: StatusTrip.FINISHED));
        add(EmitUpdateStatusSocketIO());
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
            'driver/rating/trip', (route) => false,
            arguments: state.clientRequestResponse);
      }
    });
  }

  @override
  Future<void> close() {
    _isClosed = true;
    timer?.cancel();
    timer = null;
    positionSubscription?.cancel();
    return super.close();
  }
}
