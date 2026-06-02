import 'package:rabbit_flutter/src/data/repository/DriverBikeInfoRepository.dart';

class GetDriverBikeInfoUseCase {

  DriverBikeInfoRepository driverBikeInfoRepository;
  GetDriverBikeInfoUseCase(this.driverBikeInfoRepository);
  run(int idDriver) => driverBikeInfoRepository.getDriverBikeInfo(idDriver);
}