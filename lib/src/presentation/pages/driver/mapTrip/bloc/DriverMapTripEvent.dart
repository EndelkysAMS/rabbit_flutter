import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart'
    show ClientRequestResponse;

abstract class DriverMapTripEvent {}

class InitDriverMapTripEvent extends DriverMapTripEvent {}

class GetClientRequest extends DriverMapTripEvent {
  final int idClientRequest;
  GetClientRequest({required this.idClientRequest});
}

class SetClientRequestData extends DriverMapTripEvent {
  final ClientRequestResponse clientRequest;
  SetClientRequestData({required this.clientRequest});
}
class GetTimeAndDistanceValues extends DriverMapTripEvent {}

class AddPolyline extends DriverMapTripEvent {
  final String idPolyline;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  AddPolyline({
    required this.idPolyline,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
  });
}

class UpdatePolyline extends DriverMapTripEvent {
  final LatLng driverPosition;

  UpdatePolyline({required this.driverPosition});
}

class ChangeMapCameraPosition extends DriverMapTripEvent {
  final double lat;
  final double lng;

  ChangeMapCameraPosition({
    required this.lat,
    required this.lng,
  });
}
class AddMarkerPickup extends DriverMapTripEvent {
  final double lat;
  final double lng;
  AddMarkerPickup({
    required this.lat,
    required this.lng,
  });
}

class AddMarkerDestination extends DriverMapTripEvent {
  final double lat;
  final double lng;
  AddMarkerDestination({
    required this.lat,
    required this.lng,
  });
}

class RemoveMarker extends DriverMapTripEvent {
  final String idMarker;
  RemoveMarker({
    required this.idMarker
  });
}

class FindPosition extends DriverMapTripEvent {}
class UpdateLocation extends DriverMapTripEvent {
  final Position position;
  UpdateLocation({required this.position});
}
class StopLocation extends DriverMapTripEvent {}
class AddMyPositionMarker extends DriverMapTripEvent {
  final double lat;
  final double lng;
  AddMyPositionMarker({ required this.lat, required this.lng });
}
class EmitDriverPositionSocketIO extends DriverMapTripEvent {
  final double lat;
  final double lng;
  final int idClient;
  final int? idClientRequest;

  EmitDriverPositionSocketIO({
    required this.lat,
    required this.lng,
    required this.idClient,
    this.idClientRequest,
  });
}
class EmitUpdateStatusSocketIO extends DriverMapTripEvent {}
class UpdateStatusToArrived extends DriverMapTripEvent {
}
class UpdateStatusToFinished extends DriverMapTripEvent {
}