import 'dart:convert';

import 'package:rabbit_flutter/src/domain/models/DriverBikeInfo.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';

DriverTripRequest driverTripRequestFromJson(String str) =>
    DriverTripRequest.fromJson(json.decode(str));

String driverTripRequestToJson(DriverTripRequest data) =>
    json.encode(data.toJson());

class DriverTripRequest {
  int? id;
  int idDriver;
  int idClientRequest;
  double fareOffered;
  double time;
  double distance;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? driver;
  DriverBikeInfo? bike;

  DriverTripRequest(
      {this.id,
      required this.idDriver,
      required this.idClientRequest,
      required this.fareOffered,
      required this.time,
      required this.distance,
      this.createdAt,
      this.updatedAt,
      this.driver,
      this.bike});

  factory DriverTripRequest.fromJson(Map<String, dynamic> json) =>
      DriverTripRequest(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ''),
        idDriver: _toInt(json["id_driver"]),
        idClientRequest: _toInt(json["id_client_request"]),
        fareOffered: _toDouble(json["fare_offered"]),
        time: _toDouble(json["time"]),
        distance: _toDouble(json["distance"]),
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
        driver: json["driver"] != null ? User.fromJson(json["driver"]) : null,
        bike:
            json["bike"] != null ? DriverBikeInfo.fromJson(json["bike"]) : null,
      );

  static List<DriverTripRequest> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(DriverTripRequest.fromJson)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        "id_driver": idDriver,
        "id_client_request": idClientRequest,
        "fare_offered": fareOffered,
        "time": time,
        "distance": distance,
      };

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
