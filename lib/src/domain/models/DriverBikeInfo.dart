import 'dart:convert';

DriverBikeInfo driverCarInfoFromJson(String str) => DriverBikeInfo.fromJson(json.decode(str));

String driverCarInfoToJson(DriverBikeInfo data) => json.encode(data.toJson());

class DriverBikeInfo {
    int? idDriver;
    String brand;
    String plate;
    String color;

    DriverBikeInfo({
        this.idDriver,
        required this.brand,
        required this.plate,
        required this.color,
    });

    factory DriverBikeInfo.fromJson(Map<String, dynamic> json) => DriverBikeInfo(
        idDriver: json["id_driver"],
        brand: json["brand"],
        plate: json["plate"],
        color: json["color"],
    );

    Map<String, dynamic> toJson() => {
        "id_driver": idDriver,
        "brand": brand,
        "plate": plate,
        "color": color,
    };
}