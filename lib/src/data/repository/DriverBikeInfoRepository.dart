import 'package:rabbit_flutter/src/domain/models/DriverBikeInfo.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

abstract class DriverBikeInfoRepository {

  Future<Resource<bool>> create(DriverBikeInfo driverBikeInfo);
  Future<Resource<DriverBikeInfo>> getDriverBikeInfo(int idDriver);

}