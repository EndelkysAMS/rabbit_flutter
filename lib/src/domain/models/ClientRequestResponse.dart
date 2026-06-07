import 'dart:convert';

import 'package:rabbit_flutter/src/domain/models/DriverBikeInfo.dart';

ClientRequestResponse clientRequestResponseFromJson(String str) =>
    ClientRequestResponse.fromJson(json.decode(str));

String clientRequestResponseToJson(ClientRequestResponse data) =>
    json.encode(data.toJson());

class ClientRequestResponse {
  int id;
  int idClient;
  String fareOffered;
  String pickupDescription;
  String destinationDescription;
  DateTime updatedAt;
  DateTime? createdAt;
  Position pickupPosition;
  Position destinationPosition;
  double? distance;
  String? timeDifference;
  Client client;
  Client? driver;
  GoogleDistanceMatrix? googleDistanceMatrix;
  int? idDriverAssigned;
  double? fareAssigned;
  DriverBikeInfo? bike;

  ClientRequestResponse(
      {required this.id,
      required this.idClient,
      required this.fareOffered,
      required this.pickupDescription,
      required this.destinationDescription,
      required this.updatedAt,
      required this.client,
      required this.pickupPosition,
      required this.destinationPosition,
      this.createdAt,
      this.distance,
      this.timeDifference,
      this.googleDistanceMatrix,
      this.fareAssigned,
      this.idDriverAssigned,
      this.driver,
      this.bike});

  static List<ClientRequestResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map>()
        .map((json) =>
            ClientRequestResponse.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Construye el viaje directamente desde el payload del socket
  /// `driver_assigned/{idDriver}` (objeto `trip`). El backend usa
  /// `id_client_request` en lugar de `id` y puede omitir `updated_at`.
  factory ClientRequestResponse.fromTripPayload(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return ClientRequestResponse(
      id: json["id"] ?? json["id_client_request"],
      idClient: json["id_client"],
      fareOffered: json["fare_offered"]?.toString() ?? '',
      pickupDescription: json["pickup_description"] ?? '',
      destinationDescription: json["destination_description"] ?? '',
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now(),
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      client: Client.fromJson(json["client"]),
      pickupPosition: Position.fromJson(json["pickup_position"]),
      destinationPosition: Position.fromJson(json["destination_position"]),
      distance: toDouble(json["distance"]),
      timeDifference: json["time_difference"]?.toString(),
      driver: json["driver"] != null ? Client.fromJson(json["driver"]) : null,
      idDriverAssigned: json["id_driver_assigned"],
      fareAssigned: toDouble(json["fare_assigned"]),
      googleDistanceMatrix: json["google_distance_matrix"] != null
          ? GoogleDistanceMatrix.fromJson(json["google_distance_matrix"])
          : null,
      bike: json["bike"] != null ? DriverBikeInfo.fromJson(json["bike"]) : null,
    );
  }

  factory ClientRequestResponse.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    String toStringValue(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString();
    }

    Map<String, dynamic> asMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return <String, dynamic>{};
    }

    return ClientRequestResponse(
      id: toInt(json["id"] ?? json["id_client_request"]),
      idClient: toInt(json["id_client"]),
      fareOffered: toStringValue(json["fare_offered"]),
      pickupDescription: toStringValue(json["pickup_description"]),
      destinationDescription: toStringValue(json["destination_description"]),
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now(),
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      client: Client.fromJson(asMap(json["client"])),
      pickupPosition: Position.fromJson(asMap(json["pickup_position"])),
      destinationPosition:
          Position.fromJson(asMap(json["destination_position"])),
      distance: toDouble(json["distance"]),
      timeDifference: toStringValue(json["time_difference"], fallback: ''),
      driver: json["driver"] != null
          ? Client.fromJson(asMap(json["driver"]))
          : null,
      idDriverAssigned: json["id_driver_assigned"] != null
          ? toInt(json["id_driver_assigned"])
          : null,
      fareAssigned: toDouble(json["fare_assigned"]),
      googleDistanceMatrix: json["google_distance_matrix"] != null
          ? GoogleDistanceMatrix.fromJson(asMap(json["google_distance_matrix"]))
          : null,
      bike: json["bike"] != null
          ? DriverBikeInfo.fromJson(asMap(json["bike"]))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_client": idClient,
        "fare_offered": fareOffered,
        "pickup_description": pickupDescription,
        "destination_description": destinationDescription,
        "updated_at": updatedAt.toIso8601String(),
        "pickup_position": pickupPosition.toJson(),
        "destination_position": destinationPosition.toJson(),
        "distance": distance,
        "time_difference": timeDifference,
        "client": client.toJson(),
        "google_distance_matrix": googleDistanceMatrix?.toJson(),
        "id_driver_assigned": idDriverAssigned,
        "fare_assigned": fareAssigned,
        "driver": driver,
        "bike": bike?.toJson()
      };
}

class Client {
  String name;
  dynamic image;
  String phone;
  String lastname;

  Client({
    required this.name,
    required this.image,
    required this.phone,
    required this.lastname,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        name: json["name"]?.toString() ?? '',
        image: json["image"],
        phone: json["phone"]?.toString() ?? '',
        lastname: json["lastname"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "phone": phone,
        "lastname": lastname,
      };
}

class Position {
  double x;
  double y;

  Position({
    required this.x,
    required this.y,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        x: (json["x"] as num?)?.toDouble() ?? 0,
        y: (json["y"] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}

class GoogleDistanceMatrix {
  Distance distance;
  Distance duration;
  String status;

  GoogleDistanceMatrix({
    required this.distance,
    required this.duration,
    required this.status,
  });

  factory GoogleDistanceMatrix.fromJson(Map<String, dynamic> json) =>
      GoogleDistanceMatrix(
        distance: Distance.fromJson(
            Map<String, dynamic>.from((json["distance"] as Map?) ?? {})),
        duration: Distance.fromJson(
            Map<String, dynamic>.from((json["duration"] as Map?) ?? {})),
        status: json["status"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "distance": distance.toJson(),
        "duration": duration.toJson(),
        "status": status,
      };
}

class Distance {
  String text;
  int value;

  Distance({
    required this.text,
    required this.value,
  });

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
        text: json["text"]?.toString() ?? '',
        value: (json["value"] is int)
            ? json["value"]
            : int.tryParse(json["value"]?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "value": value,
      };
}
