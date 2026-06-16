import 'package:rabbit_flutter/src/domain/repository/DriversPositionRepository.dart';

class GetNearbyDriversUseCase {
  final DriverPositionRepository driversPositionRepository;

  GetNearbyDriversUseCase(this.driversPositionRepository);

  run(double clientLat, double clientLng) =>
      driversPositionRepository.getNearbyDrivers(clientLat, clientLng);
}
