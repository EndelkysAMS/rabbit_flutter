import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/main.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/models/StatusTrip.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripState.dart';

class DriverMapTripBloc extends Bloc<DriverMapTripEvent, DriverMapTripState> {
  BlocSocketIO blocSocketIO;
  StreamSubscription? positionSubscription;
  bool _isClosed = false;
  ClientRequestsUseCases clientRequestsUseCases;
  GeolocatorUseCases geolocatorUseCases;

  DriverMapTripBloc(
      this.blocSocketIO, this.clientRequestsUseCases, this.geolocatorUseCases)
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
      if (state.position != null && state.clientRequestResponse != null) {
        List<LatLng> polylineCoordinates =
            await geolocatorUseCases.getPolyline.run(
          LatLng(event.originLat, event.originLng),
          LatLng(event.destinationLat, event.destinationLng),
        );
        if (polylineCoordinates.isEmpty) {
          // Fallback para no dejar el mapa sin ruta visible.
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
        emit(state.copyWith(polylines: {id: polyline}));
      }
    });

    on<FindPosition>((event, emit) async {
      geolocator.Position position =
          await geolocatorUseCases.findPosition.run();
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
      ));
      add(AddPolyline(
        idPolyline: "pickup_polyline",
        originLat: state.position!.latitude,
        originLng: state.position!.longitude,
        destinationLat: state.clientRequestResponse!.pickupPosition.x,
        destinationLng: state.clientRequestResponse!.pickupPosition.y,
      ));
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
      add(AddMyPositionMarker(
          lat: event.position.latitude, lng: event.position.longitude));
      add(ChangeMapCameraPosition(
          lat: event.position.latitude, lng: event.position.longitude));
      emit(state.copyWith(position: event.position));
      if (state.clientRequestResponse != null) {
        final status = state.statusTrip;
        final toDestination = status == StatusTrip.ARRIVED;
        add(AddPolyline(
          idPolyline:
              toDestination ? "destination_polyline" : "pickup_polyline",
          originLat: event.position.latitude,
          originLng: event.position.longitude,
          destinationLat: toDestination
              ? state.clientRequestResponse!.destinationPosition.x
              : state.clientRequestResponse!.pickupPosition.x,
          destinationLng: toDestination
              ? state.clientRequestResponse!.destinationPosition.y
              : state.clientRequestResponse!.pickupPosition.y,
        ));
      }
      add(EmitDriverPositionSocketIO());
    });

    on<StopLocation>((event, emit) {
      positionSubscription?.cancel();
    });

    on<EmitDriverPositionSocketIO>((event, emit) async {
      if (state.clientRequestResponse != null) {
        blocSocketIO.state.socket?.emit('trip_change_driver_position', {
          'id_client': state.clientRequestResponse!.idClient,
          'lat': state.position!.latitude,
          'lng': state.position!.longitude,
        });
      }
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
        add(EmitUpdateStatusSocketIO());
      }
    });

    on<UpdateStatusToFinished>((event, emit) async {
      Resource response = await clientRequestsUseCases.updateStatusClientRequest
          .run(state.clientRequestResponse!.id, StatusTrip.FINISHED);
      if (response is Success) {
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
    positionSubscription?.cancel();
    return super.close();
  }
}
