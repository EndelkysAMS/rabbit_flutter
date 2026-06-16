import 'package:rabbit_flutter/src/domain/models/AdminLineaCreateDriver.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDashboard.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaDriver.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaProfile.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

abstract class AdminLineaRepository {
  Future<Resource<AdminLineaDashboard>> getDashboard();
  Future<Resource<List<AdminLineaDriver>>> getDrivers({bool? isActive});
  Future<Resource<AdminLineaDriver>> createDriver(
      AdminLineaCreateDriver createDriver);
  Future<Resource<bool>> deactivateDriver(int idDriver);
  Future<Resource<bool>> reactivateDriver(int idDriver);
  Future<Resource<bool>> deleteDriver(int idDriver);
  Future<Resource<bool>> updateProfile(AdminLineaProfile profile);
}

