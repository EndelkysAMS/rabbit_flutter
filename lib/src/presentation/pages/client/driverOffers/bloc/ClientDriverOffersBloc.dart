import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/driver-trip-request/DriverTripRequestUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersState.dart';

class ClientDriverOffersBloc
    extends Bloc<ClientDriverOffersEvent, ClientDriverOffersState> {
  BlocSocketIO blocSocketIO;
  DriverTripRequestUseCases driverTripRequestUseCases;
  ClientRequestsUseCases clientRequestsUseCases;
  String? _subscribedOfferEvent;
  bool _isSocketReconnectListenerAttached = false;
  bool _isGenericOfferListenerAttached = false;
  Timer? _pollingTimer;

  ClientDriverOffersBloc(this.blocSocketIO, this.driverTripRequestUseCases,
      this.clientRequestsUseCases)
      : super(ClientDriverOffersState()) {
    on<GetDriverOffers>((event, emit) async {
      if (event.idClientRequest <= 0) {
        emit(
          state.copyWith(
            responseDriverOffers: ErrorData('idClientRequest inválido'),
            activeClientRequestId: event.idClientRequest,
          ),
        );
        return;
      }
      Resource<List<DriverTripRequest>> response =
          await driverTripRequestUseCases.getDriverTripOffersByClientRequest
              .run(event.idClientRequest);
      if (response is Success<List<DriverTripRequest>>) {
        final uniqueOffers = _dedupeOffers(response.data);
        response = Success(uniqueOffers);
      }
      emit(state.copyWith(
        responseDriverOffers: response,
        activeClientRequestId: event.idClientRequest,
      ));
    });

    on<ListenNewDriverOfferSocketIO>((event, emit) {
      if (event.idClientRequest <= 0) {
        emit(
          state.copyWith(
            responseDriverOffers: ErrorData('idClientRequest inválido'),
            isRealtimeEnabled: false,
          ),
        );
        return;
      }
      emit(state.copyWith(
        activeClientRequestId: event.idClientRequest,
        isRealtimeEnabled: true,
      ));
      if (blocSocketIO.state.socket == null) {
        blocSocketIO.add(ConnectSocketIO());
      }
      if (blocSocketIO.state.socket != null) {
        _attachSocketListeners(event.idClientRequest);
      }
      _startPolling();
      add(GetDriverOffers(idClientRequest: event.idClientRequest));
    });

    on<StopListenNewDriverOfferSocketIO>((event, emit) {
      _detachOfferListener();
      emit(state.copyWith(
          isRealtimeEnabled: false, activeClientRequestId: null));
      _stopPolling();
    });

    on<AssignDriver>((event, emit) async {
      Resource<bool> response = await clientRequestsUseCases
          .updateDriverAssigned
          .run(event.idClientRequest, event.idDriver, event.fareAssigned);
      emit(state.copyWith(responseAssignDriver: response));
      if (response is Success) {
        add(EmitNewClientRequestSocketIO(
            idClientRequest: event.idClientRequest));
        add(EmitNewDriverAssignedSocketIO(
            idClientRequest: event.idClientRequest, idDriver: event.idDriver));
      }
    });

    on<EmitNewClientRequestSocketIO>((event, emit) {
      if (blocSocketIO.state.socket != null) {
        blocSocketIO.state.socket?.emit(
            'new_client_request', {'id_client_request': event.idClientRequest});
      }
    });

    on<EmitNewDriverAssignedSocketIO>((event, emit) {
      if (blocSocketIO.state.socket != null) {
        blocSocketIO.state.socket?.emit('new_driver_assigned', {
          'id_client_request': event.idClientRequest,
          'id_driver': event.idDriver
        });
      }
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final id = state.activeClientRequestId;
      if (state.isRealtimeEnabled && blocSocketIO.state.socket == null) {
        blocSocketIO.add(ConnectSocketIO());
      }
      if (blocSocketIO.state.socket != null && id != null && id > 0) {
        _attachSocketListeners(id);
      }
      if (state.isRealtimeEnabled && id != null && id > 0) {
        add(GetDriverOffers(idClientRequest: id));
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _attachSocketListeners(int idClientRequest) {
    final socket = blocSocketIO.state.socket;
    if (socket == null || idClientRequest <= 0) return;

    final offerEvent = 'created_driver_offer/$idClientRequest';
    if (_subscribedOfferEvent != offerEvent) {
      _detachOfferListener();
      socket.on(offerEvent, (data) {
        add(GetDriverOffers(idClientRequest: idClientRequest));
      });
      _subscribedOfferEvent = offerEvent;
    }

    if (!_isGenericOfferListenerAttached) {
      socket.on('created_driver_offer', (data) {
        final activeId = state.activeClientRequestId;
        if (activeId == null || activeId <= 0) return;
        final emittedId = _extractClientRequestId(data);
        if (emittedId == null || emittedId == activeId) {
          add(GetDriverOffers(idClientRequest: activeId));
        }
      });
      _isGenericOfferListenerAttached = true;
    }

    if (!_isSocketReconnectListenerAttached) {
      socket.on('connect', (_) {
        final activeId = state.activeClientRequestId;
        if (activeId != null && activeId > 0) {
          _attachSocketListeners(activeId);
          add(GetDriverOffers(idClientRequest: activeId));
        }
      });
      _isSocketReconnectListenerAttached = true;
    }
  }

  void _detachOfferListener() {
    final socket = blocSocketIO.state.socket;
    final eventName = _subscribedOfferEvent;
    if (socket != null && eventName != null) {
      socket.off(eventName);
    }
    if (socket != null && _isGenericOfferListenerAttached) {
      socket.off('created_driver_offer');
      _isGenericOfferListenerAttached = false;
    }
    _subscribedOfferEvent = null;
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

  List<DriverTripRequest> _dedupeOffers(List<DriverTripRequest> offers) {
    final map = LinkedHashMap<String, DriverTripRequest>();
    for (final offer in offers) {
      final key = offer.id != null
          ? 'id_${offer.id}'
          : 'd_${offer.idDriver}_c_${offer.idClientRequest}_${offer.fareOffered}';
      map[key] = offer;
    }
    return map.values.toList();
  }

  @override
  Future<void> close() {
    _detachOfferListener();
    _stopPolling();
    return super.close();
  }
}
