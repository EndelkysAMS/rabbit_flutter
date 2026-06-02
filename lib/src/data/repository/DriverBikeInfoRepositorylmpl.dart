import 'package:rabbit_flutter/src/data/dataSource/remote/services/DriverBikeInfoService.dart';
import 'package:rabbit_flutter/src/data/repository/DriverBikeInfoRepository.dart';
import 'package:rabbit_flutter/src/domain/models/DriverBikeInfo.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

class DriverBikeInfoRepositoryImpl implements DriverBikeInfoRepository{

  DriverBikeInfoService driverBikeInfoService;

  DriverBikeInfoRepositoryImpl(this.driverBikeInfoService);

  @override
  Future<Resource<bool>> create(DriverBikeInfo driverBikeInfo) {
    return driverBikeInfoService.create(driverBikeInfo);
  }

  @override
  Future<Resource<DriverBikeInfo>> getDriverBikeInfo(int idDriver) {
    return driverBikeInfoService.getDriverBikeInfo(idDriver);
  }



}