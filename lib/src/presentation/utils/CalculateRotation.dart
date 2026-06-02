import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateRotation(LatLng from, LatLng to) {
  double deltaLng = to.longitude - from.longitude;
  double deltaLat = to.latitude - from.latitude;

  double angle = atan2(deltaLng, deltaLat) * (180 / pi);
  return (angle + 360) % 360; // Asegurar un ángulo positivo entre 0-360
}

double distanceBetween(LatLng pos1, LatLng pos2) {
  return Geolocator.distanceBetween(
      pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
}