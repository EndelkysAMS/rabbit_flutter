import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart'
    as socket_events;
import 'package:rabbit_flutter/src/domain/models/DriverPosition.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/socket/SocketUseCases.dart';
import 'package:rabbit_flutter/src/debug/agent_debug_log.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/bloc/DriverMapLocationEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/bloc/DriverMapLocationState.dart';
import 'package:socket_io_client/socket_io_client.dart';

class DriverMapLocationBloc
    extends Bloc<DriverMapLocationEvent, DriverMapLocationState> {
  SocketUseCases socketUseCases;
  GeolocatorUseCases geolocatorUseCases;
  AuthUseCases authUseCases;
  DriversPositionUseCases driversPositionUseCases;
  StreamSubscription? positionSubscription;
  bool _isClosed = false;
  double? _pendingCameraLat;
  double? _pendingCameraLng;
  BlocSocketIO blocSocketIO;

  DriverMapLocationBloc(this.blocSocketIO, this.geolocatorUseCases,
      this.socketUseCases, this.authUseCases, this.driversPositionUseCases)
      : super(DriverMapLocationState()) {
    on<DriverMapLocationInitEvent>((event, emit) async {
      final authResponse = await authUseCases.getUserSession.run();
      final idDriver = authResponse.user.id;
      // #region agent log
      agentDebugLog(
        location: 'DriverMapLocationBloc.dart:Init',
        message: 'Driver init',
        data: {
          'idDriver': idDriver,
          'markerAsset': 'assets/img/moto_pin.png',
          'controllerCompleted': state.controller?.isCompleted ?? false,
        },
        hypothesisId: 'D',
      );
      // #endregion
      emit(state.copyWith(idDriver: idDriver));
    });

    on<FindPosition>((event, emit) async {
      positionSubscription?.cancel();
      Position position;
      try {
        position = await geolocatorUseCases.findPosition.run();
      } catch (e) {
        final message = _mapLocationError(e);
        // #region agent log
        agentDebugLog(
          location: 'DriverMapLocationBloc.dart:FindPosition',
          message: 'FindPosition failed',
          data: {'error': e.toString(), 'userMessage': message},
          hypothesisId: 'C',
        );
        // #endregion
        emit(state.copyWith(locationError: message));
        return;
      }
      // #region agent log
      agentDebugLog(
        location: 'DriverMapLocationBloc.dart:FindPosition',
        message: 'FindPosition ok',
        data: {
          'lat': position.latitude,
          'lng': position.longitude,
          'idDriver': state.idDriver,
          'controllerCompleted': state.controller?.isCompleted ?? false,
        },
        hypothesisId: 'A,C',
        runId: 'post-fix',
      );
      // #endregion
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
      emit(state.copyWith(position: position, clearLocationError: true));
      add(EmitDriverPositionSocketIO());
    });

    on<AddMyPositionMarker>((event, emit) async {
      try {
        BitmapDescriptor descriptor = await geolocatorUseCases.createMarker
            .run('assets/img/moto_pin.png');
        Marker marker = geolocatorUseCases.getMarker.run(
            'my_location',
            event.lat,
            event.lng,
            'Mi posición',
            '',
            descriptor,
            anchor: const Offset(0.5, 1.0));
        print('[DriverMap] marker set lat=${event.lat} lng=${event.lng}');
        // #region agent log
        agentDebugLog(
          location: 'DriverMapLocationBloc.dart:AddMyPositionMarker',
          message: 'Marker set',
          data: {
            'lat': event.lat,
            'lng': event.lng,
            'markerAsset': 'assets/img/moto_pin.png',
          },
          hypothesisId: 'D',
          runId: 'post-fix',
        );
        // #endregion
        emit(state.copyWith(
          markers: {marker.markerId: marker},
        ));
      } catch (e) {
        print('[DriverMap] AddMyPositionMarker error: $e');
        // #region agent log
        agentDebugLog(
          location: 'DriverMapLocationBloc.dart:AddMyPositionMarker',
          message: 'Marker fallback',
          data: {
            'lat': event.lat,
            'lng': event.lng,
            'error': e.toString(),
            'markerAsset': 'assets/img/moto_pin.png',
          },
          hypothesisId: 'D',
        );
        // #endregion
        final fallback = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
        Marker marker = geolocatorUseCases.getMarker.run(
            'my_location',
            event.lat,
            event.lng,
            'Mi posición',
            '',
            fallback,
            anchor: const Offset(0.5, 1.0));
        emit(state.copyWith(
          markers: {marker.markerId: marker},
        ));
      }
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      _pendingCameraLat = event.lat;
      _pendingCameraLng = event.lng;
      await _tryAnimateCamera();
    });

    on<RetryPendingCamera>((event, emit) async {
      await _tryAnimateCamera();
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

    void emitDriverPosition(Socket socket) {
      socket.emit('change_driver_position', {
        'id': state.idDriver,
        'lat': state.position!.latitude,
        'lng': state.position!.longitude,
      });
      // #region agent log
      agentDebugLog(
        location: 'DriverMapLocationBloc.dart:EmitDriverPositionSocketIO',
        message: 'Socket emit',
        data: {
          'idDriver': state.idDriver,
          'lat': state.position!.latitude,
          'lng': state.position!.longitude,
          'connected': socket.connected,
        },
        hypothesisId: 'B',
      );
      // #endregion
      print('[DriverMap] socket emit id=${state.idDriver} '
          'lat=${state.position!.latitude} lng=${state.position!.longitude}');
    }

    on<EmitDriverPositionSocketIO>((event, emit) async {
      if (state.idDriver == null || state.position == null) return;
      try {
        final socket = socketUseCases.connect.run();
        if (blocSocketIO.state.socket == null) {
          blocSocketIO.add(socket_events.ConnectSocketIO());
        }
        if (socket.connected) {
          emitDriverPosition(socket);
        } else {
          socket.once('connect', (_) {
            if (!_isClosed && state.idDriver != null && state.position != null) {
              emitDriverPosition(socket);
            }
          });
          // #region agent log
          agentDebugLog(
            location: 'DriverMapLocationBloc.dart:EmitDriverPositionSocketIO',
            message: 'Socket waiting for connect',
            data: {'idDriver': state.idDriver},
            hypothesisId: 'B',
          );
          // #endregion
        }
      } catch (e) {
        print('[DriverMap] socket emit error: $e');
        // #region agent log
        agentDebugLog(
          location: 'DriverMapLocationBloc.dart:EmitDriverPositionSocketIO',
          message: 'Socket error',
          data: {'error': e.toString()},
          hypothesisId: 'B',
        );
        // #endregion
      }
    });

    on<SaveLocationData>((event, emit) async {
      await driversPositionUseCases.createDriverPosition
          .run(event.driverPosition);
    });

    on<DeleteLocationData>((event, emit) async {
      await driversPositionUseCases.deleteDriverPosition.run(event.idDriver);
    });
  }

  String _mapLocationError(Object error) {
    final text = error.toString();
    if (text.contains('Location services are disabled')) {
      return 'Activa el GPS del teléfono para ver tu ubicación en el mapa.';
    }
    if (text.contains('permanently denied')) {
      return 'Permiso de ubicación bloqueado. Ábrelo en Ajustes de la app.';
    }
    if (text.contains('permissions are denied')) {
      return 'Permiso de ubicación denegado. Actívalo para usar el mapa.';
    }
    return 'No se pudo obtener tu ubicación. Revisa GPS y permisos.';
  }

  Future<void> _tryAnimateCamera() async {
    final lat = _pendingCameraLat;
    final lng = _pendingCameraLng;
    if (lat == null || lng == null) return;
    try {
      if (_isClosed || state.controller == null) return;
      if (!state.controller!.isCompleted) {
        // #region agent log
        agentDebugLog(
          location: 'DriverMapLocationBloc.dart:ChangeMapCameraPosition',
          message: 'Camera pending - controller not ready',
          data: {'lat': lat, 'lng': lng},
          hypothesisId: 'A',
        );
        // #endregion
        return;
      }
      final googleMapController = await state.controller!.future;
      if (_isClosed) return;
      await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 13, bearing: 0)));
      _pendingCameraLat = null;
      _pendingCameraLng = null;
      // #region agent log
      agentDebugLog(
        location: 'DriverMapLocationBloc.dart:ChangeMapCameraPosition',
        message: 'Camera moved',
        data: {'lat': lat, 'lng': lng},
        hypothesisId: 'A',
      );
      // #endregion
    } catch (e) {
      print('ERROR EN ChangeMapCameraPosition: $e');
      // #region agent log
      agentDebugLog(
        location: 'DriverMapLocationBloc.dart:ChangeMapCameraPosition',
        message: 'Camera error',
        data: {'error': e.toString()},
        hypothesisId: 'A',
      );
      // #endregion
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    positionSubscription?.cancel();
    return super.close();
  }
}
