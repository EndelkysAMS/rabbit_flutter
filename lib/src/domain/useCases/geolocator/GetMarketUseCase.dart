import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/src/domain/repository/GeolocatorRepository.dart';

class GetMarkerUseCase {
  GeolocatorRepository geolocatorRepository;
  GetMarkerUseCase(this.geolocatorRepository);
  run(String markerId, double lat, double lng, String title, String content,
          BitmapDescriptor imageMarker,
          {Offset anchor = const Offset(0.5, 0.5)}) =>
      geolocatorRepository.getMarker(
          markerId, lat, lng, title, content, imageMarker,
          anchor: anchor);
}