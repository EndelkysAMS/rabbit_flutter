import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';

class SuperLine {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;
  final SuperLineSubscription subscription;

  SuperLine({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
    required this.subscription,
  });

  factory SuperLine.fromJson(Map<String, dynamic> json) {
    return SuperLine(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      subscription: SuperLineSubscription.fromJson(
        Map<String, dynamic>.from(json['subscription'] ?? {}),
      ),
    );
  }
}
