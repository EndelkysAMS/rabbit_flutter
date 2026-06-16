abstract class SuperDashboardEvent {}

class SuperDashboardInitEvent extends SuperDashboardEvent {}

class LoadSuperLinesEvent extends SuperDashboardEvent {}

class ActivateSuperLineEvent extends SuperDashboardEvent {
  final int lineId;
  ActivateSuperLineEvent({required this.lineId});
}

class SuspendSuperLineEvent extends SuperDashboardEvent {
  final int lineId;
  SuspendSuperLineEvent({required this.lineId});
}

class RecordSuperLinePaymentEvent extends SuperDashboardEvent {
  final int lineId;
  final String? plan;
  final String? notes;
  RecordSuperLinePaymentEvent({
    required this.lineId,
    this.plan,
    this.notes,
  });
}

class PatchSuperLineSubscriptionEvent extends SuperDashboardEvent {
  final int lineId;
  final String? plan;
  final String? status;
  final String? notes;
  PatchSuperLineSubscriptionEvent({
    required this.lineId,
    this.plan,
    this.status,
    this.notes,
  });
}

class DeleteSuperLineEvent extends SuperDashboardEvent {
  final int lineId;
  DeleteSuperLineEvent({required this.lineId});
}

class ClearSuperActionResponseEvent extends SuperDashboardEvent {}

class LogoutSuperEvent extends SuperDashboardEvent {}
