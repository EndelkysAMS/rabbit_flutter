import 'package:rabbit_flutter/src/data/dataSource/remote/services/AdminLineaService.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaCreateDriver.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDashboard.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDriver.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaProfile.dart';
import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class AdminLineaRepositoryImpl implements AdminLineaRepository {
  final AdminLineaService adminLineaService;

  AdminLineaRepositoryImpl(this.adminLineaService);

  @override
  Future<Resource<AdminLineaDashboard>> getDashboard() {
    return adminLineaService.getDashboard();
  }

  @override
  Future<Resource<List<AdminLineaDriver>>> getDrivers({bool? isActive}) {
    return adminLineaService.getDrivers(isActive: isActive);
  }

  @override
  Future<Resource<AdminLineaDriver>> createDriver(
      AdminLineaCreateDriver createDriver) {
    return adminLineaService.createDriver(createDriver);
  }

  @override
  Future<Resource<bool>> deactivateDriver(int idDriver) {
    return adminLineaService.deactivateDriver(idDriver);
  }

  @override
  Future<Resource<bool>> reactivateDriver(int idDriver) {
    return adminLineaService.reactivateDriver(idDriver);
  }

  @override
  Future<Resource<bool>> deleteDriver(int idDriver) {
    return adminLineaService.deleteDriver(idDriver);
  }

  @override
  Future<Resource<bool>> updateProfile(AdminLineaProfile profile) {
    return adminLineaService.updateProfile(profile);
  }
}

