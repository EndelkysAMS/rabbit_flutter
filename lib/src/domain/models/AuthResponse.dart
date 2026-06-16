import 'dart:convert';

import 'package:rabbit_flutter/src/domain/models/user.dart';

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  User user;
  String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final root =
        json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    final userJson = root['user'];
    if (userJson is! Map) {
      throw FormatException('Login: falta el objeto user en la respuesta');
    }
    return AuthResponse(
      user: User.fromJson(Map<String, dynamic>.from(userJson)),
      token: _extractToken(root),
    );
  }

  static String _extractToken(Map<String, dynamic> json) {
    final raw = json['token'] ?? json['access'] ?? json['access_token'];
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      final nested = raw['access'] ?? raw['token'] ?? raw['access_token'];
      if (nested is String && nested.isNotEmpty) return nested;
    }
    throw FormatException('Login: falta el token en la respuesta');
  }

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "token": token,
      };
}
