class SuperLineSubscription {
  final String plan;
  final String status;
  final String? startedAt;
  final String? pilotEndsAt;
  final String? nextBillingAt;
  final String? lastPaymentAt;
  final int? daysUntilPilotEnd;
  final int? maxDrivers;
  final int activeDriversCount;
  final String? notes;

  SuperLineSubscription({
    required this.plan,
    required this.status,
    this.startedAt,
    this.pilotEndsAt,
    this.nextBillingAt,
    this.lastPaymentAt,
    this.daysUntilPilotEnd,
    this.maxDrivers,
    this.activeDriversCount = 0,
    this.notes,
  });

  factory SuperLineSubscription.fromJson(Map<String, dynamic> json) {
    return SuperLineSubscription(
      plan: json['plan']?.toString() ?? 'piloto',
      status: json['status']?.toString() ?? 'activa',
      startedAt: json['started_at']?.toString(),
      pilotEndsAt: json['pilot_ends_at']?.toString(),
      nextBillingAt: json['next_billing_at']?.toString(),
      lastPaymentAt: json['last_payment_at']?.toString(),
      daysUntilPilotEnd: json['days_until_pilot_end'] is num
          ? (json['days_until_pilot_end'] as num).toInt()
          : null,
      maxDrivers: json['max_drivers'] is num
          ? (json['max_drivers'] as num).toInt()
          : null,
      activeDriversCount: json['active_drivers_count'] is num
          ? (json['active_drivers_count'] as num).toInt()
          : 0,
      notes: json['notes']?.toString(),
    );
  }
}
