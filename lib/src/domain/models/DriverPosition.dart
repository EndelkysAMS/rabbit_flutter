import 'dart:convert';

DriverPosition driverPositionFromJson(String str) => DriverPosition.fromJson(json.decode(str));

String driverPositionToJson(DriverPosition data) => json.encode(data.toJson());

class DriverPosition {
    int idDriver;
    double lat;
    double lng;
    String? name;
    String? lastname;
    String? image;

    DriverPosition({
        required this.idDriver,
        required this.lat,
        required this.lng,
        this.name,
        this.lastname,
        this.image,
    });

    factory DriverPosition.fromJson(Map<String, dynamic> json) => DriverPosition(
        idDriver: json["id_driver"],
        lat: (json["lat"] as num).toDouble(),
        lng: (json["lng"] as num).toDouble(),
        name: json["name"],
        lastname: json["lastname"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id_driver": idDriver,
        "lat": lat,
        "lng": lng,
    };
}