import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';
import 'package:rabbit_flutter/src/domain/repository/SuperAdminRepository.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class SuperAdminUseCases {
  final SuperAdminRepository repository;

  SuperAdminUseCases(this.repository);

  Future<Resource<List<SuperLine>>> getLines() => repository.getLines();

  Future<Resource<SuperLineSubscription>> activateLine(int lineId) =>
      repository.activateLine(lineId);

  Future<Resource<SuperLineSubscription>> suspendLine(int lineId) =>
      repository.suspendLine(lineId);

  Future<Resource<bool>> deleteLine(int lineId) =>
      repository.deleteLine(lineId);

  Future<Resource<SuperLineSubscription>> recordPayment({
    required int lineId,
    String? plan,
    String? notes,
    String? lastPaymentAt,
  }) =>
      repository.recordPayment(
        lineId: lineId,
        plan: plan,
        notes: notes,
        lastPaymentAt: lastPaymentAt,
      );

  Future<Resource<SuperLineSubscription>> patchSubscription({
    required int lineId,
    String? plan,
    String? status,
    String? notes,
    String? nextBillingAt,
    String? lastPaymentAt,
  }) =>
      repository.patchSubscription(
        lineId: lineId,
        plan: plan,
        status: status,
        notes: notes,
        nextBillingAt: nextBillingAt,
        lastPaymentAt: lastPaymentAt,
      );
}
