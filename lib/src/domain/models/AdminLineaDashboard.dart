import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';

class AdminLineaLineInfo {
  final int id;
  final String name;
  final SuperLineSubscription subscription;

  AdminLineaLineInfo({
    required this.id,
    required this.name,
    required this.subscription,
  });

  factory AdminLineaLineInfo.fromJson(Map<String, dynamic> json) {
    return AdminLineaLineInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name']?.toString() ?? '',
      subscription: SuperLineSubscription.fromJson(
        Map<String, dynamic>.from(json['subscription'] ?? {}),
      ),
    );
  }
}

class AdminLineaDashboard {
  final AdminLineaLineInfo line;
  final int driversActive;
  final int driversInactive;
  final int driversWithLivePosition;
  final int tripsTotal;
  final int tripsFinished;
  final int tripsToday;
  final double revenueTotalUsd;
  final double revenueTodayUsd;

  AdminLineaDashboard({
    required this.line,
    this.driversActive = 0,
    this.driversInactive = 0,
    this.driversWithLivePosition = 0,
    this.tripsTotal = 0,
    this.tripsFinished = 0,
    this.tripsToday = 0,
    this.revenueTotalUsd = 0,
    this.revenueTodayUsd = 0,
  });

  factory AdminLineaDashboard.fromJson(Map<String, dynamic> json) {
    final drivers = Map<String, dynamic>.from(json['drivers'] ?? {});
    final trips = Map<String, dynamic>.from(json['trips'] ?? {});
    final revenue = Map<String, dynamic>.from(json['revenue'] ?? {});

    return AdminLineaDashboard(
      line: AdminLineaLineInfo.fromJson(
        Map<String, dynamic>.from(json['line'] ?? {}),
      ),
      driversActive: drivers['active'] is num
          ? (drivers['active'] as num).toInt()
          : 0,
      driversInactive: drivers['inactive'] is num
          ? (drivers['inactive'] as num).toInt()
          : 0,
      driversWithLivePosition: drivers['with_live_position'] is num
          ? (drivers['with_live_position'] as num).toInt()
          : 0,
      tripsTotal:
          trips['total'] is num ? (trips['total'] as num).toInt() : 0,
      tripsFinished:
          trips['finished'] is num ? (trips['finished'] as num).toInt() : 0,
      tripsToday:
          trips['today'] is num ? (trips['today'] as num).toInt() : 0,
      revenueTotalUsd: revenue['total_finished_usd'] is num
          ? (revenue['total_finished_usd'] as num).toDouble()
          : 0,
      revenueTodayUsd: revenue['today_finished_usd'] is num
          ? (revenue['today_finished_usd'] as num).toDouble()
          : 0,
    );
  }
}
