import 'package:rabbit_flutter/src/data/dataSource/remote/services/SuperAdminService.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';
import 'package:rabbit_flutter/src/domain/repository/SuperAdminRepository.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class SuperAdminRepositoryImpl implements SuperAdminRepository {
  final SuperAdminService superAdminService;

  SuperAdminRepositoryImpl(this.superAdminService);

  @override
  Future<Resource<List<SuperLine>>> getLines() =>
      superAdminService.getLines();

  @override
  Future<Resource<SuperLineSubscription>> activateLine(int lineId) =>
      superAdminService.activateLine(lineId);

  @override
  Future<Resource<SuperLineSubscription>> suspendLine(int lineId) =>
      superAdminService.suspendLine(lineId);

  @override
  Future<Resource<bool>> deleteLine(int lineId) =>
      superAdminService.deleteLine(lineId);

  @override
  Future<Resource<SuperLineSubscription>> recordPayment({
    required int lineId,
    String? plan,
    String? notes,
    String? lastPaymentAt,
  }) =>
      superAdminService.recordPayment(
        lineId: lineId,
        plan: plan,
        notes: notes,
        lastPaymentAt: lastPaymentAt,
      );

  @override
  Future<Resource<SuperLineSubscription>> patchSubscription({
    required int lineId,
    String? plan,
    String? status,
    String? notes,
    String? nextBillingAt,
    String? lastPaymentAt,
  }) =>
      superAdminService.patchSubscription(
        lineId: lineId,
        plan: plan,
        status: status,
        notes: notes,
        nextBillingAt: nextBillingAt,
        lastPaymentAt: lastPaymentAt,
      );
}
