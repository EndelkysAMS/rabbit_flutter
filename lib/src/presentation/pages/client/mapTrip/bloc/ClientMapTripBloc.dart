import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/main.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/models/DriverPosition.dart';
import 'package:rabbit_flutter/src/domain/models/StatusTrip.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart';
import 'package:rabbit_flutter/src/domain/models/TimeAndDistanceValues.dart'
    as TD;
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripState.dart';
import 'package:rabbit_flutter/src/presentation/utils/CalculateRotation.dart';

class ClientMapTripBloc extends Bloc<ClientMapTripEvent, ClientMapTripState> {
  Timer? timer;
  BlocSocketIO blocSocketIO;
  ClientRequestsUseCases clientRequestsUseCases;
  DriversPositionUseCases driversPositionUseCases;
  GeolocatorUseCases geolocatorUseCases;
  AuthUseCases authUseCases;
  String? _tripDriverPositionEventName;
  String? _tripDriverPositionByRequestEventName;
  String? _tripStatusEventName;
  bool _connectListenerAttached = false;
  bool _didFocusDriverInitial = false;
  BitmapDescriptor _driverBikeIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  bool _driverBikeIconReady = false;
  Timer? _driverPositionPollingTimer;

  void _startOrRefreshEtaTimer() {
    timer?.cancel();
    // Actualiza ETA con frecuencia para reflejar avance del conductor.
    timer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (isClosed || state.driverLatLng == null) return;
      add(GetTimeAndDistanceValues(
          driverLat: state.driverLatLng!.latitude,
          driverLng: state.driverLatLng!.longitude));
    });
  }

  Future<void> _ensureDriverBikeIconLoaded() async {
    if (_driverBikeIconReady) return;
    try {
      _driverBikeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(44, 44)),
        'assets/img/moto_pin.png',
      );
      _driverBikeIconReady = true;
      print('moto icon loaded OK');
    } catch (e) {
      _driverBikeIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      _driverBikeIconReady = true;
      print('moto icon loaded FAIL: $e');
    }
  }

  ClientMapTripBloc(this.blocSocketIO, this.clientRequestsUseCases,
      this.driversPositionUseCases, this.geolocatorUseCases, this.authUseCases)
      : super(ClientMapTripState()) {
    on<InitClientMapTripEvent>((event, emit) async {
      Completer<GoogleMapController> controller =
          Completer<GoogleMapController>();
      await _ensureDriverBikeIconLoaded();
      emit(state.copyWith(
        controller: controller,
      ));
    });

    on<AddMarkerPickup>((event, emit) async {
      BitmapDescriptor pickUpDescriptor = await geolocatorUseCases.createMarker
          .run('assets/img/person_location.png');
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

    on<AddMarkerDriver>((event, emit) async {
      const MarkerId markerId = MarkerId('driver_marker');
      LatLng newLatLng = LatLng(event.lat, event.lng);
      await _ensureDriverBikeIconLoaded();

      Marker marker = Marker(
        markerId: markerId,
        position: newLatLng,
        rotation: 0,
        draggable: false,
        flat: true,
        icon: _driverBikeIcon,
        anchor: const Offset(0.5, 0.5),
        zIndex: 50,
      );

      emit(state.copyWith(
        markers: Map.of(state.markers)..[markerId] = marker,
      ));
      print('driver_marker updated lat=${event.lat} lng=${event.lng}');
      print('markers rendered count=${state.markers.length}');
    });

    on<AddPolyline>((event, emit) async {
      List<LatLng> polylineCoordinates = await geolocatorUseCases.getPolyline
          .run(LatLng(event.driverLat, event.driverLng),
              LatLng(event.destinationLat, event.destinationLng));
      if (polylineCoordinates.isEmpty) {
        // Fallback visual: si Google no devuelve ruta, mostramos al menos
        // una linea directa entre origen y destino.
        polylineCoordinates = [
          LatLng(event.driverLat, event.driverLng),
          LatLng(event.destinationLat, event.destinationLng),
        ];
      }
      PolylineId id = PolylineId("MyRoute");
      Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.orange,
          points: polylineCoordinates,
          width: 8);
      emit(state.copyWith(
        polylines: {id: polyline},
        isRouteDrawed: polylineCoordinates.isNotEmpty,
      ));
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      try {
        GoogleMapController googleMapController =
            await state.controller!.future;
        await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(event.lat, event.lng), zoom: 12, bearing: 0)));
      } catch (e) {
        print('Error ChangeMapCameraPosition: $e');
      }
    });

    on<GetClientRequest>((event, emit) async {
      Resource response = await clientRequestsUseCases.getByClientRequest
          .run(event.idClientRequest);
      emit(state.copyWith(responseGetClientRequest: response));
      if (response is Success) {
        final data = response.data as ClientRequestResponse;
        emit(state.copyWith(clientRequestResponse: data));
        add(AddMarkerPickup(
            lat: data.pickupPosition.x, lng: data.pickupPosition.y));
        add(AddMarkerDestination(
            lat: data.destinationPosition.x, lng: data.destinationPosition.y));
        add(ListenUpdateStatusClientRequestSocketIO());
      }
    });

    on<GetTimeAndDistanceValues>((event, emit) async {
      Resource response = await clientRequestsUseCases.getTimeAndDistance.run(
        event.driverLat,
        event.driverLng,
        state.clientRequestResponse!.pickupPosition.x,
        state.clientRequestResponse!.pickupPosition.y,
      );
      if (response is Success) {
        final data = response.data as TD.TimeAndDistanceValues;
        print('Time and Distance: ${data.toJson()}');
        emit(state.copyWith(timeAndDistanceValues: data));
      }
    });

    on<SetDriverLatLng>((event, emit) {
      LatLng driverPosition = LatLng(event.lat, event.lng);
      print(
          'socket trip_new_driver_position received lat=${event.lat} lng=${event.lng}');
      emit(state.copyWith(driverLatLng: driverPosition));
      add(AddMarkerDriver(
          lat: state.driverLatLng!.latitude,
          lng: state.driverLatLng!.longitude));
      if (!_didFocusDriverInitial) {
        _didFocusDriverInitial = true;
        add(ChangeMapCameraPosition(lat: event.lat, lng: event.lng));
      }
      if (!state.isRouteDrawed) {
        add(AddPolyline(
          driverLat: state.driverLatLng!.latitude,
          driverLng: state.driverLatLng!.longitude,
          destinationLat: state.clientRequestResponse!.pickupPosition.x,
          destinationLng: state.clientRequestResponse!.pickupPosition.y,
        ));
        add(GetTimeAndDistanceValues(
            driverLat: state.driverLatLng!.latitude,
            driverLng: state.driverLatLng!.longitude));
        _startOrRefreshEtaTimer();
      } else {
        add(AddPolyline(
          driverLat: state.driverLatLng!.latitude,
          driverLng: state.driverLatLng!.longitude,
          destinationLat: state.clientRequestResponse!.pickupPosition.x,
          destinationLng: state.clientRequestResponse!.pickupPosition.y,
        ));
        // Aunque la ruta ya exista, seguimos refrescando ETA para ver avance.
        _startOrRefreshEtaTimer();
      }
    });

    on<UpdatePolyline>((event, emit) {
      if (state.polylines.isNotEmpty) {
        PolylineId id = PolylineId("MyRoute");
        Polyline? polyline = state.polylines[id];

        if (polyline != null) {
          List<LatLng> updatedPoints = List.from(polyline.points);

          int index = updatedPoints.indexWhere(
              (point) => distanceBetween(event.driverPosition, point) < 20);
          if (index != -1) {
            updatedPoints = updatedPoints.sublist(index + 1);
          }

          if (updatedPoints.isEmpty) {
            emit(state.copyWith(polylines: {}));
          } else {
            emit(state.copyWith(polylines: {
              id: polyline.copyWith(pointsParam: updatedPoints)
            }));
          }
        }
      }
    });

    on<ListenTripNewDriverPosition>((event, emit) async {
      if (blocSocketIO.state.socket == null) {
        blocSocketIO.add(ConnectSocketIO());
        Future.delayed(const Duration(milliseconds: 600), () {
          add(ListenTripNewDriverPosition());
        });
        return;
      }
      AuthResponse authResponse = await authUseCases.getUserSession.run();
      final socket = blocSocketIO.state.socket;
      if (socket == null) return;
      final byClientEvent = 'trip_new_driver_position/${authResponse.user.id}';
      final byRequestEvent = state.clientRequestResponse != null
          ? 'trip_new_driver_position/${state.clientRequestResponse!.id}'
          : null;
      if (_tripDriverPositionEventName != byClientEvent) {
        if (_tripDriverPositionEventName != null) {
          socket.off(_tripDriverPositionEventName!);
        }
        _tripDriverPositionEventName = byClientEvent;
      }
      _subscribeDriverPositionEvent(byClientEvent);
      if (byRequestEvent != null &&
          _tripDriverPositionByRequestEventName != byRequestEvent) {
        if (_tripDriverPositionByRequestEventName != null) {
          socket.off(_tripDriverPositionByRequestEventName!);
        }
        _tripDriverPositionByRequestEventName = byRequestEvent;
      }
      if (byRequestEvent != null) {
        _subscribeDriverPositionEvent(byRequestEvent);
      }
      _attachConnectRebindListener();
      _startDriverPositionPollingFallback();
    });

    on<ListenUpdateStatusClientRequestSocketIO>((event, emit) {
      final clientRequest = state.clientRequestResponse;
      if (clientRequest == null) return;
      if (blocSocketIO.state.socket == null) {
        blocSocketIO.add(ConnectSocketIO());
        Future.delayed(const Duration(milliseconds: 600), () {
          add(ListenUpdateStatusClientRequestSocketIO());
        });
        return;
      }
      final socket = blocSocketIO.state.socket;
      if (socket == null) return;
      final eventName = 'new_status_trip/${clientRequest.id}';
      if (_tripStatusEventName != eventName) {
        if (_tripStatusEventName != null) {
          socket.off(_tripStatusEventName!);
        }
        _tripStatusEventName = eventName;
      }
      socket.off(eventName);
      socket.on(eventName, (data) {
        String statusTrip = data['status'] as String;
        if (statusTrip == StatusTrip.ARRIVED.name) {
          timer?.cancel();
          timer = null;
          add(AddPolyline(
              driverLat: state.driverLatLng!.latitude,
              driverLng: state.driverLatLng!.longitude,
              destinationLat:
                  state.clientRequestResponse!.destinationPosition.x,
              destinationLng:
                  state.clientRequestResponse!.destinationPosition.y));
          add(RemoveMarker(idMarker: 'pickup'));
          add(AddMarkerDestination(
              lat: state.clientRequestResponse!.destinationPosition.x,
              lng: state.clientRequestResponse!.destinationPosition.y));
        } else if (statusTrip == StatusTrip.FINISHED.name) {
          timer?.cancel();
          timer = null;
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
              'client/rating/trip', (route) => false,
              arguments: state.clientRequestResponse);
        }
      });
      _attachConnectRebindListener();
    });

    on<RemoveMarker>((event, emit) {
      emit(state.copyWith(
          markers: Map.of(state.markers)..remove(MarkerId(event.idMarker))));
    });
  }

  @override
  Future<void> close() {
    final socket = blocSocketIO.state.socket;
    if (socket != null) {
      if (_tripDriverPositionEventName != null) {
        socket.off(_tripDriverPositionEventName!);
      }
      if (_tripDriverPositionByRequestEventName != null) {
        socket.off(_tripDriverPositionByRequestEventName!);
      }
      if (_tripStatusEventName != null) {
        socket.off(_tripStatusEventName!);
      }
      if (_connectListenerAttached) {
        socket.off('connect');
      }
    }
    timer?.cancel();
    timer = null;
    _driverPositionPollingTimer?.cancel();
    _driverPositionPollingTimer = null;
    return super.close();
  }

  void _attachConnectRebindListener() {
    final socket = blocSocketIO.state.socket;
    if (socket == null || _connectListenerAttached) return;
    socket.on('connect', (_) {
      add(ListenTripNewDriverPosition());
      add(ListenUpdateStatusClientRequestSocketIO());
    });
    _connectListenerAttached = true;
  }

  void _subscribeDriverPositionEvent(String eventName) {
    final socket = blocSocketIO.state.socket;
    if (socket == null) return;
    socket.off(eventName);
    socket.on(eventName, (data) {
      double? _toDouble(dynamic value) {
        if (value is num) return value.toDouble();
        return double.tryParse(value?.toString() ?? '');
      }

      final rawLat = _toDouble(data['lat']);
      final rawLng = _toDouble(data['lng']);
      if (rawLat == null || rawLng == null) return;

      double lat = rawLat;
      double lng = rawLng;
      final request = state.clientRequestResponse;
      if (request != null) {
        final pickup =
            LatLng(request.pickupPosition.x, request.pickupPosition.y);
        final asIs = distanceBetween(LatLng(lat, lng), pickup);
        final swapped = distanceBetween(LatLng(lng, lat), pickup);
        if (swapped + 20 < asIs) {
          final tmp = lat;
          lat = lng;
          lng = tmp;
        }
      }

      print(
          'socket $eventName received lat=$lat lng=$lng (raw: $rawLat,$rawLng)');
      add(SetDriverLatLng(lat: lat, lng: lng));
    });
  }

  void _startDriverPositionPollingFallback() {
    _driverPositionPollingTimer?.cancel();
    _driverPositionPollingTimer =
        Timer.periodic(const Duration(seconds: 3), (_) async {
      final request = state.clientRequestResponse;
      final idDriver = request?.idDriverAssigned;
      if (request == null || idDriver == null || idDriver <= 0) return;
      final response =
          await driversPositionUseCases.getDriverPosition.run(idDriver);
      if (response is Success<DriverPosition>) {
        final pos = response.data;
        add(SetDriverLatLng(lat: pos.lat, lng: pos.lng));
      }
    });
  }
}
