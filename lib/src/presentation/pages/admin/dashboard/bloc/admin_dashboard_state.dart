import 'package:equatable/equatable.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDriver.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

const _unset = Object();

class AdminDashboardState extends Equatable {
  final User? adminUser;
  final Resource? responseDrivers;
  final Resource? responseInactiveDrivers;
  final Resource? responseCreateDriver;
  final Resource? responseDeactivateDriver;
  final Resource? responseDeleteDriver;
  final Resource? responseUpdateProfile;
  final bool didLogout;
  final List<AdminLineaDriver> drivers;
  final List<AdminLineaDriver> inactiveDrivers;

  const AdminDashboardState({
    this.adminUser,
    this.responseDrivers,
    this.responseInactiveDrivers,
    this.responseCreateDriver,
    this.responseDeactivateDriver,
    this.responseDeleteDriver,
    this.responseUpdateProfile,
    this.didLogout = false,
    this.drivers = const [],
    this.inactiveDrivers = const [],
  });

  AdminDashboardState copyWith({
    User? adminUser,
    Object? responseDrivers = _unset,
    Object? responseInactiveDrivers = _unset,
    Object? responseCreateDriver = _unset,
    Object? responseDeactivateDriver = _unset,
    Object? responseDeleteDriver = _unset,
    Object? responseUpdateProfile = _unset,
    bool? didLogout,
    List<AdminLineaDriver>? drivers,
    List<AdminLineaDriver>? inactiveDrivers,
  }) {
    return AdminDashboardState(
      adminUser: adminUser ?? this.adminUser,
      responseDrivers: identical(responseDrivers, _unset)
          ? this.responseDrivers
          : responseDrivers as Resource?,
      responseInactiveDrivers: identical(responseInactiveDrivers, _unset)
          ? this.responseInactiveDrivers
          : responseInactiveDrivers as Resource?,
      responseCreateDriver: identical(responseCreateDriver, _unset)
          ? this.responseCreateDriver
          : responseCreateDriver as Resource?,
      responseDeactivateDriver: identical(responseDeactivateDriver, _unset)
          ? this.responseDeactivateDriver
          : responseDeactivateDriver as Resource?,
      responseDeleteDriver: identical(responseDeleteDriver, _unset)
          ? this.responseDeleteDriver
          : responseDeleteDriver as Resource?,
      responseUpdateProfile: identical(responseUpdateProfile, _unset)
          ? this.responseUpdateProfile
          : responseUpdateProfile as Resource?,
      didLogout: didLogout ?? this.didLogout,
      drivers: drivers ?? this.drivers,
      inactiveDrivers: inactiveDrivers ?? this.inactiveDrivers,
    );
  }

  @override
  List<Object?> get props => [
        adminUser,
        responseDrivers,
        responseInactiveDrivers,
        responseCreateDriver,
        responseDeactivateDriver,
        responseDeleteDriver,
        responseUpdateProfile,
        didLogout,
        drivers,
        inactiveDrivers,
      ];
}
