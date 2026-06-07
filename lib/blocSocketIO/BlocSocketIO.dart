import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOState.dart';
import 'package:rabbit_flutter/main.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/socket/SocketUseCases.dart';
import 'package:socket_io_client/socket_io_client.dart';

class BlocSocketIO extends Bloc<BlocSocketIOEvent, BlocSocketIOState> {
  SocketUseCases socketUseCases;
  AuthUseCases authUseCases;

  BlocSocketIO(this.socketUseCases, this.authUseCases)
      : super(BlocSocketIOState()) {
    on<ConnectSocketIO>((event, emit) {
      Socket socket = socketUseCases.connect.run();
      emit(state.copyWith(socket: socket));
    });

    on<DisconnectSocketIO>((event, emit) {
      socketUseCases.disconnect.run();
      emit(state.copyWith(socket: null));
    });

    on<ListenDriverAssignedSocketIO>((event, emit) async {
      if (state.socket != null) {
        AuthResponse? authResponse = await authUseCases.getUserSession.run();
        if (authResponse != null) {
          final int? myId = authResponse.user.id;
          final eventName = 'driver_assigned/$myId';
          state.socket?.off(eventName);
          state.socket?.on(eventName, (data) {
            print('DRIVER_ASSIGNED DATA: $data');
            final idClientRequest = _extractInt(
                data is Map ? data['id_client_request'] : null);
            final idDriver =
                _extractInt(data is Map ? data['id_driver'] : null);
            if (idClientRequest == null) return;
            final bool isAssignedDriver =
                myId != null && idDriver != null && myId == idDriver;

            if (isAssignedDriver) {
              // Poblamos la pantalla del viaje directamente desde `trip`
              // para evitar un segundo GET y la demora asociada.
              final trip = data is Map ? data['trip'] : null;
              if (trip is Map) {
                try {
                  final clientRequest = ClientRequestResponse.fromTripPayload(
                      Map<String, dynamic>.from(trip));
                  navigatorKey.currentState?.pushNamed(
                    'driver/map/trip',
                    arguments: clientRequest,
                  );
                  return;
                } catch (e) {
                  print('Error parseando trip del socket: $e');
                }
              }
              // Fallback: si `trip` viene nulo o malformado, pasamos el id
              // y la pantalla hará GET /client-requests/{id}.
              navigatorKey.currentState?.pushNamed(
                'driver/map/trip',
                arguments: idClientRequest,
              );
            } else {
              navigatorKey.currentState?.pushNamed(
                'client/map/trip',
                arguments: idClientRequest,
              );
            }
          });
        }
      }
    });
  }

  int? _extractInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
