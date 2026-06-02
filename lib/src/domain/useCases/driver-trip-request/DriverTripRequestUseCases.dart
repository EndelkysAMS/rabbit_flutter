import 'package:rabbit_flutter/src/domain/useCases/driver-trip-request/CreateDriverTripRequestUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/driver-trip-request/GetDriverTripOffersByClientRequestsUseCase.dart';

class DriverTripRequestUseCases {

  CreateDriverTripRequestUseCase createDriverTripRequest;
  GetDriverTripOffersByClientRequestUseCase getDriverTripOffersByClientRequest;

  DriverTripRequestUseCases({
    required this.createDriverTripRequest,
    required this.getDriverTripOffersByClientRequest,
  });

}