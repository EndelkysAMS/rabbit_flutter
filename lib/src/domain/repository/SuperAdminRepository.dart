import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

abstract class SuperAdminRepository {
  Future<Resource<List<SuperLine>>> getLines();
  Future<Resource<SuperLineSubscription>> activateLine(int lineId);
  Future<Resource<SuperLineSubscription>> suspendLine(int lineId);
  Future<Resource<bool>> deleteLine(int lineId);
  Future<Resource<SuperLineSubscription>> recordPayment({
    required int lineId,
    String? plan,
    String? notes,
    String? lastPaymentAt,
  });
  Future<Resource<SuperLineSubscription>> patchSubscription({
    required int lineId,
    String? plan,
    String? status,
    String? notes,
    String? nextBillingAt,
    String? lastPaymentAt,
  });
}
