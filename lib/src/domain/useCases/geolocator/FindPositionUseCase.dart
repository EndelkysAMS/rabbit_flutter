import 'package:rabbit_flutter/src/domain/repository/GeolocatorRepository.dart';

class FindPositionUseCase {

 GeolocatorRepository geolocatorRepository;

 FindPositionUseCase(this.geolocatorRepository);

 run() => geolocatorRepository.findPosition();

}