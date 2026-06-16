import 'package:rabbit_flutter/src/domain/models/Role.dart';

class User {
    int? id;
    String name;
    String lastname;
    String? email;
    String phone;
    String? password;
    String? image;
    dynamic notificationToken;
    DateTime? createdAt;
    DateTime? updatedAt;
    List<Role>? roles;

    User({
        this.id,
        required this.name,
        required this.lastname,
        this.email,
        required this.phone,
        this.image,
        this.password,
        this.notificationToken,
        this.createdAt,
        this.updatedAt,
        this.roles,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString() ?? '',
        lastname: json["lastname"]?.toString() ?? '',
        email: json["email"]?.toString(),
        phone: json["phone"]?.toString() ?? '',
        image: json["image"]?.toString(),
        password: json["password"]?.toString(),
        notificationToken: json["notification_token"],
        roles: json["roles"] != null
            ? List<Role>.from(json["roles"].map((x) => Role.fromJson(x)))
            : [],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lastname": lastname,
        "email": email,
        "phone": phone,
        "image": image,
        'password': password,
        "notification_token": notificationToken,
        "roles": roles != null ? List<dynamic>.from(roles!.map((x) => x.toJson())) : [],
    };
}