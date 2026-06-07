import 'package:equatable/equatable.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class DriverClientRequestsState extends Equatable {
  final Resource? response;
  final Resource? responseCreateDriverTripRequest;
  final Resource? responseDriverPosition;
  final BlocFormItem fareOffered;
  final int? idDriver;
  final int? activeRequestId;
  final bool isRealtimeEnabled;
  final List<ClientRequestResponse> nearbyRequests;

  DriverClientRequestsState({
    this.response,
    this.responseCreateDriverTripRequest,
    this.responseDriverPosition,
    this.fareOffered = const BlocFormItem(error: 'Ingresa la tarifa'),
    this.idDriver,
    this.activeRequestId,
    this.isRealtimeEnabled = false,
    this.nearbyRequests = const [],
  });

  DriverClientRequestsState copyWith({
    Resource? response,
    Resource? responseCreateDriverTripRequest,
    Resource? responseDriverPosition,
    BlocFormItem? fareOffered,
    int? idDriver,
    int? activeRequestId,
    bool? isRealtimeEnabled,
    List<ClientRequestResponse>? nearbyRequests,
  }) {
    return DriverClientRequestsState(
      response: response ?? this.response,
      responseDriverPosition:
          responseDriverPosition ?? this.responseDriverPosition,
      responseCreateDriverTripRequest: responseCreateDriverTripRequest,
      fareOffered: fareOffered ?? this.fareOffered,
      idDriver: idDriver ?? this.idDriver,
      activeRequestId: activeRequestId ?? this.activeRequestId,
      isRealtimeEnabled: isRealtimeEnabled ?? this.isRealtimeEnabled,
      nearbyRequests: nearbyRequests ?? this.nearbyRequests,
    );
  }

  @override
  List<Object?> get props => [
        response,
        responseCreateDriverTripRequest,
        responseDriverPosition,
        fareOffered,
        idDriver,
        activeRequestId,
        isRealtimeEnabled,
        nearbyRequests
      ];
}
