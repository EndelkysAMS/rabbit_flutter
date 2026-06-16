import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart'
    as socket_events;
import 'package:rabbit_flutter/src/domain/models/PlacemarkData.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/socket/SocketUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapSeeker/bloc/ClientMapSeekerEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapSeeker/bloc/ClientMapSeekerState.dart';

class ClientMapSeekerBloc
    extends Bloc<ClientMapSeekerEvent, ClientMapSeekerState> {
  GeolocatorUseCases geolocatorUseCases;
  SocketUseCases socketUseCases;
  DriversPositionUseCases driversPositionUseCases;
  BlocSocketIO blocSocketIO;
  BitmapDescriptor? _driverMarkerIcon;

  ClientMapSeekerBloc(
    this.blocSocketIO,
    this.geolocatorUseCases,
    this.socketUseCases,
    this.driversPositionUseCases,
  ) : super(ClientMapSeekerState()) {
    on<ClientMapSeekerInitEvent>((event, emit) {
      final controller = Completer<GoogleMapController>();
      emit(state.copyWith(
        controller: controller,
        markers: const <MarkerId, Marker>{},
      ));
    });

    on<FindPosition>((event, emit) async {
      Position position = await geolocatorUseCases.findPosition.run();
      add(ChangeMapCameraPosition(
          lat: position.latitude, lng: position.longitude));
      emit(state.copyWith(
        position: position,
      ));
      add(LoadNearbyDriversEvent(
        lat: position.latitude,
        lng: position.longitude,
      ));
    });

    on<LoadNearbyDriversEvent>((event, emit) async {
      final response = await driversPositionUseCases.getNearbyDrivers.run(
        event.lat,
        event.lng,
      );
      if (response is! Success) return;

      final icon = await _driverMarkerIconDescriptor();
      final markers = Map<MarkerId, Marker>.from(state.markers);
      markers.removeWhere((key, _) => key.value.startsWith('driver_'));

      for (final driver in response.data) {
        if (!_isValidCoordinate(driver.lat, driver.lng)) continue;
        final markerId = _driverMarkerId(driver.idDriver);
        markers[markerId] = Marker(
          markerId: markerId,
          position: LatLng(driver.lat, driver.lng),
          rotation: 0,
          draggable: false,
          flat: true,
          icon: icon,
        );
      }
      emit(state.copyWith(markers: markers));
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      try {
        GoogleMapController googleMapController =
            await state.controller!.future;
        await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(event.lat, event.lng), zoom: 13, bearing: 0)));
      } catch (e) {
        print('ERROR EN ChangeMapCameraPosition: $e');
      }
    });

    on<OnCameraMove>((event, emit) {
      emit(state.copyWith(cameraPosition: event.cameraPosition));
    });

    on<OnCameraIdle>((event, emit) async {
      try {
        PlacemarkData placemarkData =
            await geolocatorUseCases.getPlacemarkData.run(state.cameraPosition);
        emit(state.copyWith(placemarkData: placemarkData));
      } catch (e) {
        print('OnCameraIdle Error: $e');
      }
    });

    on<OnAutoCompletedPickUpSelected>((event, emit) {
      emit(state.copyWith(
          pickUpLatLng: LatLng(event.lat, event.lng),
          pickUpDescription: event.pickUpDescription));
    });

    on<OnAutoCompletedDestinationSelected>((event, emit) {
      emit(state.copyWith(
          destinationLatLng: LatLng(event.lat, event.lng),
          destinationDescription: event.destinationDescription));
    });

    on<ListenDriversPositionSocketIO>((event, emit) async {
      if (blocSocketIO.state.socket == null) {
        blocSocketIO.add(socket_events.ConnectSocketIO());
      }
      socketUseCases.connect.run();
      final socket = blocSocketIO.state.socket ?? socketUseCases.connect.run();
      if (socket == null) return;
      socket.off('new_driver_position');
      socket.on('new_driver_position', (data) {
        if (data is! Map) return;
        final id = _asInt(data['id']);
        final lat = _asDouble(data['lat']);
        final lng = _asDouble(data['lng']);
        if (id == null || !_isValidCoordinate(lat, lng)) return;
        add(AddDriverPositionMarker(
          id: id,
          lat: lat,
          lng: lng,
        ));
      });
    });

    on<ListenDriversDisconnectedSocketIO>((event, emit) {
      final socket = blocSocketIO.state.socket;
      if (socket == null) return;
      socket.off('driver_disconnected');
      socket.on('driver_disconnected', (data) {
        if (data is! Map) return;
        final id = _asInt(data['id_driver'] ?? data['id']);
        if (id == null) return;
        add(RemoveDriverPositionMarker(driverId: id));
      });
    });

    on<RemoveDriverPositionMarker>((event, emit) {
      emit(state.copyWith(
        markers: Map.of(state.markers)
          ..remove(_driverMarkerId(event.driverId)),
      ));
    });

    on<AddDriverPositionMarker>((event, emit) async {
      if (!_isValidCoordinate(event.lat, event.lng)) return;

      final markerId = _driverMarkerId(event.id);
      final icon = await _driverMarkerIconDescriptor();
      final marker = Marker(
        markerId: markerId,
        position: LatLng(event.lat, event.lng),
        rotation: 0,
        draggable: false,
        flat: true,
        icon: icon,
      );

      emit(state.copyWith(
        markers: Map.of(state.markers)..[markerId] = marker,
      ));
    });
  }

  MarkerId _driverMarkerId(int driverId) => MarkerId('driver_$driverId');

  bool _isValidCoordinate(double lat, double lng) {
    if (lat == 0 && lng == 0) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return true;
  }

  Future<BitmapDescriptor> _driverMarkerIconDescriptor() async {
    _driverMarkerIcon ??=
        await geolocatorUseCases.createMarker.run('assets/img/motorbike.png');
    return _driverMarkerIcon!;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
