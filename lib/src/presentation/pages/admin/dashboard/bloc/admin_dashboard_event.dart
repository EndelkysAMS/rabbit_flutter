import 'package:rabbit_flutter/src/domain/models/AdminLineaCreateDriver.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaProfile.dart';

abstract class AdminDashboardEvent {}

class AdminDashboardInitEvent extends AdminDashboardEvent {}

class LoadAdminPlanEvent extends AdminDashboardEvent {}

class LoadDriversEvent extends AdminDashboardEvent {}

class LoadInactiveDriversEvent extends AdminDashboardEvent {}

class CreateDriverEvent extends AdminDashboardEvent {
  final AdminLineaCreateDriver createDriver;
  CreateDriverEvent({required this.createDriver});
}

class DeactivateDriverEvent extends AdminDashboardEvent {
  final int idDriver;
  DeactivateDriverEvent({required this.idDriver});
}

class ReactivateDriverEvent extends AdminDashboardEvent {
  final int idDriver;
  ReactivateDriverEvent({required this.idDriver});
}

class DeleteDriverEvent extends AdminDashboardEvent {
  final int idDriver;
  DeleteDriverEvent({required this.idDriver});
}

class UpdateAdminProfileEvent extends AdminDashboardEvent {
  final AdminLineaProfile profile;
  UpdateAdminProfileEvent({required this.profile});
}

class ClearCreateDriverResponseEvent extends AdminDashboardEvent {}

class ClearDeactivateDriverResponseEvent extends AdminDashboardEvent {}

class ClearReactivateDriverResponseEvent extends AdminDashboardEvent {}

class ClearDeleteDriverResponseEvent extends AdminDashboardEvent {}

class ClearUpdateProfileResponseEvent extends AdminDashboardEvent {}

class LogoutAdminEvent extends AdminDashboardEvent {}

