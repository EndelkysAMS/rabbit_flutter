import 'package:equatable/equatable.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class ClientDriverOffersState extends Equatable {

  final Resource? responseDriverOffers;
  final Resource? responseAssignDriver;
  final int? activeClientRequestId;
  final bool isRealtimeEnabled;

  const ClientDriverOffersState({
    this.responseDriverOffers,
    this.responseAssignDriver,
    this.activeClientRequestId,
    this.isRealtimeEnabled = false,
  });

  ClientDriverOffersState copyWith({
    Resource? responseDriverOffers,
    Resource? responseAssignDriver,
    int? activeClientRequestId,
    bool? isRealtimeEnabled,
  }) {
    return ClientDriverOffersState(
      responseDriverOffers: responseDriverOffers ?? this.responseDriverOffers,
      responseAssignDriver: responseAssignDriver,
      activeClientRequestId: activeClientRequestId ?? this.activeClientRequestId,
      isRealtimeEnabled: isRealtimeEnabled ?? this.isRealtimeEnabled,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [responseDriverOffers, responseAssignDriver, activeClientRequestId, isRealtimeEnabled];

}