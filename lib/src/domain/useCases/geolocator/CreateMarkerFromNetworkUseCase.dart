import 'package:rabbit_flutter/src/domain/repository/GeolocatorRepository.dart';

class CreateMarkerFromNetworkUseCase {
  GeolocatorRepository geolocatorRepository;

  CreateMarkerFromNetworkUseCase(this.geolocatorRepository);

  run(String? url) => geolocatorRepository.createMarkerFromNetwork(url);
}
