import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ClientMapSeekerEvent {}

class ClientMapSeekerInitEvent extends ClientMapSeekerEvent {}

class FindPosition extends ClientMapSeekerEvent {}

class LoadNearbyDriversEvent extends ClientMapSeekerEvent {
  final double lat;
  final double lng;

  LoadNearbyDriversEvent({required this.lat, required this.lng});
}

class ChangeMapCameraPosition extends ClientMapSeekerEvent {
  final double lat;
  final double lng;

  ChangeMapCameraPosition({
    required this.lat,
    required this.lng,
  });
}

class OnCameraMove extends ClientMapSeekerEvent {
  CameraPosition cameraPosition;
  OnCameraMove({required this.cameraPosition});
}

class OnCameraIdle extends ClientMapSeekerEvent {}

class OnAutoCompletedPickUpSelected extends ClientMapSeekerEvent {
  double lat;
  double lng;
  String pickUpDescription;
  OnAutoCompletedPickUpSelected(
      {required this.lat, required this.lng, required this.pickUpDescription});
}

class OnAutoCompletedDestinationSelected extends ClientMapSeekerEvent {
  double lat;
  double lng;
  String destinationDescription;
  OnAutoCompletedDestinationSelected(
      {required this.lat,
      required this.lng,
      required this.destinationDescription});
}

class ListenDriversPositionSocketIO extends ClientMapSeekerEvent {}

class ListenDriversDisconnectedSocketIO extends ClientMapSeekerEvent {}

class RemoveDriverPositionMarker extends ClientMapSeekerEvent {
  final int driverId;

  RemoveDriverPositionMarker({required this.driverId});
}

class AddDriverPositionMarker extends ClientMapSeekerEvent {
  final int id;
  final double lat;
  final double lng;

  AddDriverPositionMarker({
    required this.id,
    required this.lat,
    required this.lng,
  });
}
