class GeoCoords {
  static ({double lat, double lng}) normalize(double rawLat, double rawLng) {
    double lat = rawLat;
    double lng = rawLng;

    if (lat.abs() > 90 && lng.abs() <= 90) {
      final tmp = lat;
      lat = lng;
      lng = tmp;
    } else if (lng.abs() > 90 && lat.abs() <= 90) {
      // already lat, lng
    } else if (lat.abs() > 45 && lng.abs() <= 45) {
      final tmp = lat;
      lat = lng;
      lng = tmp;
    } else if (lng.abs() > 45 && lat.abs() <= 45) {
      // already lat, lng
    }

    return (lat: lat, lng: lng);
  }

  static bool isValid(double lat, double lng) {
    return lat.abs() <= 90 && lng.abs() <= 180 && !(lat == 0 && lng == 0);
  }
}
