import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rabbit_flutter/src/data/api/ApiKeyGoogle.dart';
import 'package:rabbit_flutter/src/domain/models/PlacemarkData.dart';
import 'package:rabbit_flutter/src/domain/repository/GeolocatorRepository.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class GeolocatorRepositoryImpl implements GeolocatorRepository {
  @override
  Future<Position> findPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('La ubicacion no esta activada');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permiso no otorgado por el usuario');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permiso no otorgado por el usuario permanentemente');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (Platform.isAndroid) {
      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  static const _markerAssetFallbacks = [
    'assets/img/pin.png',
    'assets/img/role_driver.png',
  ];

  @override
  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    final candidates = [path, ..._markerAssetFallbacks.where((p) => p != path)];
    for (final assetPath in candidates) {
      try {
        return await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)),
          assetPath,
        );
      } catch (e) {
        print('Marker asset failed ($assetPath): $e');
      }
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  }

  static const _networkMarkerFallbacks = [
    'assets/img/role_driver.png',
    'assets/img/moto_pin.png',
  ];

  @override
  Future<BitmapDescriptor> createMarkerFromNetwork(String? url) async {
    final trimmed = url?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(trimmed));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return BitmapDescriptor.fromBytes(response.bodyBytes);
        }
        print('Marker network bad status ($trimmed): ${response.statusCode}');
      } catch (e) {
        print('Marker network failed ($trimmed): $e');
      }
    }
    for (final assetPath in _networkMarkerFallbacks) {
      try {
        return await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)),
          assetPath,
        );
      } catch (e) {
        print('Marker network fallback failed ($assetPath): $e');
      }
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  }

  @override
  Marker getMarker(String markerId, double lat, double lng, String title,
      String content, BitmapDescriptor imageMarker,
      {Offset anchor = const Offset(0.5, 0.5)}) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: imageMarker,
        anchor: anchor,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content));
    return marker;
  }

  @override
  Future<PlacemarkData?> getPlacemarkData(CameraPosition cameraPosition) async {
    try {
      double lat = cameraPosition.target.latitude;
      double lng = cameraPosition.target.longitude;
      List<Placemark> placemarkList = await placemarkFromCoordinates(lat, lng);
      if (placemarkList != null) {
        if (placemarkList.length > 0) {
          String direction = placemarkList[0].thoroughfare!;
          String street = placemarkList[0].subThoroughfare!;
          String city = placemarkList[0].locality!;
          String department = placemarkList[0].administrativeArea!;
          PlacemarkData placemarkData = PlacemarkData(
              address: '$direction, $street, $city, $department',
              lat: lat,
              lng: lng);
          return placemarkData;
        }
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Future<List<LatLng>> getPolyline(
      LatLng pickUpLatLng, LatLng destinationLatLng) async {
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        request: PolylineRequest(
            origin: PointLatLng(pickUpLatLng.latitude, pickUpLatLng.longitude),
            destination: PointLatLng(
                destinationLatLng.latitude, destinationLatLng.longitude),
            mode: TravelMode.driving),
        googleApiKey: API_KEY_GOOGLE);

    List<LatLng> polylineCoordinates = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    return polylineCoordinates;
  }

  @override
  Stream<Position> getPositionStream() {
    if (Platform.isAndroid) {
      return Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          intervalDuration: const Duration(seconds: 1),
          // Mock-location apps on Android usually inject via LocationManager.
          forceLocationManager: true,
        ),
      );
    }
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    );
  }
}
