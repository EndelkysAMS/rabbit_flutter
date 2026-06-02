import 'package:rabbit_flutter/src/domain/repository/DriverTripRequestsRepository.dart';

class GetDriverTripOffersByClientRequestUseCase {

  DriverTripRequestsRepository driverTripRequestsRepository;

  GetDriverTripOffersByClientRequestUseCase(this.driverTripRequestsRepository);

  run(int idClientRequest) => driverTripRequestsRepository.getDriverTripOffersByClientRequest(idClientRequest);

}