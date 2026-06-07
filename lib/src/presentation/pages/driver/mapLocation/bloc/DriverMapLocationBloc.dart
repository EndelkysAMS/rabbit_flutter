import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/DriverPosition.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/socket/SocketUseCases.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/bloc/DriverMapLocationEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/bloc/DriverMapLocationState.dart';

class DriverMapLocationBloc
    extends Bloc<DriverMapLocationEvent, DriverMapLocationState> {
  SocketUseCases socketUseCases;
  GeolocatorUseCases geolocatorUseCases;
  AuthUseCases authUseCases;
  DriversPositionUseCases driversPositionUseCases;
  StreamSubscription? positionSubscription;
  bool _isClosed = false;
  BlocSocketIO blocSocketIO;

  DriverMapLocationBloc(this.blocSocketIO, this.geolocatorUseCases,
      this.socketUseCases, this.authUseCases, this.driversPositionUseCases)
      : super(DriverMapLocationState()) {
    on<DriverMapLocationInitEvent>((event, emit) async {
      Completer<GoogleMapController> controller =
          Completer<GoogleMapController>();
      AuthResponse authResponse = await authUseCases.getUserSession.run();
      emit(state.copyWith(
          controller: controller, idDriver: authResponse.user.id));
    });

    on<FindPosition>((event, emit) async {
      Position position = await geolocatorUseCases.findPosition.run();
      if (state.idDriver != null) {
        add(SaveLocationData(
          driverPosition: DriverPosition(
            idDriver: state.idDriver!,
            lat: position.latitude,
            lng: position.longitude,
          ),
        ));
      }
      add(ChangeMapCameraPosition(
          lat: position.latitude, lng: position.longitude));
      add(AddMyPositionMarker(lat: position.latitude, lng: position.longitude));
      Stream<Position> positionStream =
          geolocatorUseCases.getPositionStream.run();
      positionSubscription = positionStream.listen((Position position) {
        add(UpdateLocation(position: position));
        if (state.idDriver != null) {
          add(SaveLocationData(
              driverPosition: DriverPosition(
                  idDriver: state.idDriver!,
                  lat: position.latitude,
                  lng: position.longitude)));
        }
      });
      emit(state.copyWith(
        position: position,
      ));
    });

    on<AddMyPositionMarker>((event, emit) async {
      BitmapDescriptor descriptor =
          await geolocatorUseCases.createMarker.run('assets/img/moto_pin.png');
      Marker marker = geolocatorUseCases.getMarker.run(
          'my_location', event.lat, event.lng, 'Mi posición', '', descriptor);
      emit(state.copyWith(
        markers: {marker.markerId: marker},
      ));
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      try {
        if (_isClosed || state.controller == null) return;
        GoogleMapController googleMapController =
            await state.controller!.future;
        if (_isClosed) return;
        await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(event.lat, event.lng), zoom: 13, bearing: 0)));
      } catch (e) {
        print('ERROR EN ChangeMapCameraPosition: $e');
      }
    });

    on<UpdateLocation>((event, emit) async {
      add(AddMyPositionMarker(
          lat: event.position.latitude, lng: event.position.longitude));
      add(ChangeMapCameraPosition(
          lat: event.position.latitude, lng: event.position.longitude));
      emit(state.copyWith(position: event.position));
      add(EmitDriverPositionSocketIO());
    });

    on<StopLocation>((event, emit) {
      positionSubscription?.cancel();
      if (state.idDriver != null) {
        add(DeleteLocationData(idDriver: state.idDriver!));
      }
    });

    on<EmitDriverPositionSocketIO>((event, emit) async {
      blocSocketIO.state.socket?.emit('change_driver_position', {
        'id': state.idDriver,
        'lat': state.position!.latitude,
        'lng': state.position!.longitude,
      });
    });

    on<SaveLocationData>((event, emit) async {
      await driversPositionUseCases.createDriverPosition
          .run(event.driverPosition);
    });

    on<DeleteLocationData>((event, emit) async {
      await driversPositionUseCases.deleteDriverPosition.run(event.idDriver);
    });
  }

  @override
  Future<void> close() {
    _isClosed = true;
    positionSubscription?.cancel();
    return super.close();
  }
}
