import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/models/DriverPosition.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/driver-trip-request/DriverTripRequestUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsState.dart';

class DriverClientRequestsBloc
    extends Bloc<DriverClientRequestsEvent, DriverClientRequestsState> {
  AuthUseCases authUseCases;
  DriversPositionUseCases driversPositionUseCases;
  ClientRequestsUseCases clientRequestsUseCases;
  DriverTripRequestUseCases driverTripRequestUseCases;
  BlocSocketIO blocSocketIO;
  bool _isSocketListenerAttached = false;
  bool _isSocketReconnectListenerAttached = false;
  Timer? _pollingTimer;
  int? _lastSocketRequestId;

  DriverClientRequestsBloc(
      this.blocSocketIO,
      this.clientRequestsUseCases,
      this.driversPositionUseCases,
      this.authUseCases,
      this.driverTripRequestUseCases)
      : super(DriverClientRequestsState()) {
    on<InitDriverClientRequest>((event, emit) async {
      AuthResponse authResponse = await authUseCases.getUserSession.run();
      Resource responseDriverPosition = await driversPositionUseCases
          .getDriverPosition
          .run(authResponse.user.id!);
      emit(state.copyWith(
          response: Loading(),
          idDriver: authResponse.user.id!,
          responseDriverPosition: responseDriverPosition));
      add(GetNearbyTripRequest());
    });

    on<GetNearbyTripRequest>((event, emit) async {
      if (state.idDriver == null) return;
      final responseDriverPosition =
          await driversPositionUseCases.getDriverPosition.run(state.idDriver!);
      emit(state.copyWith(responseDriverPosition: responseDriverPosition));
      if (responseDriverPosition is Success) {
        DriverPosition driverPosition =
            responseDriverPosition.data as DriverPosition;
        Resource<List<ClientRequestResponse>> response =
            await clientRequestsUseCases.getNearbyTripRequest
                .run(driverPosition.lat, driverPosition.lng);
        List<ClientRequestResponse> nextNearby = state.nearbyRequests;
        int? nextActiveRequestId = state.activeRequestId;
        if (response is Success<List<ClientRequestResponse>>) {
          final fetched = response.data;
          if (state.activeRequestId != null) {
            final exact = fetched
                .where((item) => item.id == state.activeRequestId)
                .toList();
            if (exact.isNotEmpty) {
              nextNearby = exact;
              nextActiveRequestId = exact.first.id;
            } else if (fetched.isNotEmpty) {
              nextNearby = [fetched.first];
              nextActiveRequestId = fetched.first.id;
            } else if (state.nearbyRequests.isNotEmpty) {
              nextNearby = state.nearbyRequests;
            } else {
              nextNearby = [];
              nextActiveRequestId = null;
            }
          } else if (fetched.isNotEmpty) {
            nextNearby = [fetched.first];
            nextActiveRequestId = fetched.first.id;
          } else if (state.nearbyRequests.isNotEmpty) {
            nextNearby = state.nearbyRequests;
            nextActiveRequestId = state.nearbyRequests.first.id;
          } else {
            nextNearby = [];
            nextActiveRequestId = null;
          }
        }
        emit(state.copyWith(
          response: response,
          nearbyRequests: nextNearby,
          activeRequestId: nextActiveRequestId,
        ));
      }
    });

    on<SetActiveRequestById>((event, emit) {
      if (event.idClientRequest <= 0) return;
      final exact = state.nearbyRequests
          .where((item) => item.id == event.idClientRequest)
          .toList();
      if (exact.isNotEmpty) {
        emit(state.copyWith(
          activeRequestId: event.idClientRequest,
          nearbyRequests: [exact.first],
        ));
      } else {
        emit(state.copyWith(activeRequestId: event.idClientRequest));
      }
      add(GetNearbyTripRequest());
    });

    on<CreateDriverTripRequest>((event, emit) async {
      Resource<bool> response = await driverTripRequestUseCases
          .createDriverTripRequest
          .run(event.driverTripRequest);
      emit(state.copyWith(responseCreateDriverTripRequest: response));
      if (response is Success) {
        add(EmitNewDriverOfferSocketIO(
            idClientRequest: event.driverTripRequest.idClientRequest));
      }
    });

    on<FareOfferedChange>((event, emit) {
      emit(state.copyWith(fareOffered: event.fareOffered));
    });

    on<ListenNewClientRequestSocketIO>((event, emit) {
      emit(state.copyWith(isRealtimeEnabled: true));
      if (blocSocketIO.state.socket != null) {
        _attachSocketListeners();
      }
      _startPolling();
      add(GetNearbyTripRequest());
    });

    on<EnableRealtimeRequests>((event, emit) {
      emit(state.copyWith(isRealtimeEnabled: true));
      _attachSocketListeners();
      _startPolling();
      add(GetNearbyTripRequest());
    });

    on<DisableRealtimeRequests>((event, emit) {
      emit(state.copyWith(isRealtimeEnabled: false));
      _stopPolling();
    });

    on<EmitNewDriverOfferSocketIO>((event, emit) {
      if (blocSocketIO.state.socket != null) {
        blocSocketIO.state.socket?.emit(
            'new_driver_offer', {'id_client_request': event.idClientRequest});
      }
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (blocSocketIO.state.socket != null) {
        _attachSocketListeners();
      }
      if (state.isRealtimeEnabled) {
        add(GetNearbyTripRequest());
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _attachSocketListeners() {
    final socket = blocSocketIO.state.socket;
    if (socket == null) return;

    if (!_isSocketListenerAttached) {
      socket.on('created_client_request', (data) {
        _lastSocketRequestId = _extractClientRequestId(data);
        if (_lastSocketRequestId != null) {
          add(SetActiveRequestById(idClientRequest: _lastSocketRequestId!));
        }
        _showLocalTripRequestNotification();
        add(GetNearbyTripRequest());
      });
      _isSocketListenerAttached = true;
    }

    if (!_isSocketReconnectListenerAttached) {
      socket.on('connect', (_) {
        _isSocketListenerAttached = false;
        _attachSocketListeners();
        if (state.isRealtimeEnabled) {
          add(GetNearbyTripRequest());
        }
      });
      _isSocketReconnectListenerAttached = true;
    }
  }

  int? _extractClientRequestId(dynamic data) {
    if (data is Map) {
      final raw =
          data['id_client_request'] ?? data['idClientRequest'] ?? data['id'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '');
    }
    return null;
  }

  Future<void> _showLocalTripRequestNotification() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await plugin.initialize(initSettings);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'driver_trip_requests',
        'Solicitudes de viaje',
        channelDescription: 'Alertas de nuevas solicitudes para conductor',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Nueva solicitud de viaje',
      'Tienes una nueva solicitud cercana',
      details,
    );
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
