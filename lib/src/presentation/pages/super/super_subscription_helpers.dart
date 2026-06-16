import 'package:flutter/material.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';

const superOrange = Color(0xFFFF8000);

String planLabel(String plan) {
  switch (plan) {
    case 'basico':
      return 'Básico';
    case 'pro':
      return 'Pro';
    case 'piloto':
    default:
      return 'Piloto';
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'morosa':
      return 'Morosa';
    case 'suspendida':
      return 'Suspendida';
    case 'activa':
    default:
      return 'Activa';
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'morosa':
      return const Color(0xFFE6A817);
    case 'suspendida':
      return const Color(0xFFD64545);
    case 'activa':
    default:
      return const Color(0xFF2E9E5B);
  }
}

String driversLimitLabel(SuperLineSubscription sub) {
  final max = sub.maxDrivers;
  if (max == null) return '${sub.activeDriversCount} activos';
  return '${sub.activeDriversCount} / $max';
}

String formatSubscriptionDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

String formatSubscriptionDateTime(String? value) {
  if (value == null || value.isEmpty) return '—';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${formatSubscriptionDate(value)} $hour:$minute';
}

const superPlans = ['piloto', 'basico', 'pro'];
const superStatuses = ['activa', 'morosa', 'suspendida'];
