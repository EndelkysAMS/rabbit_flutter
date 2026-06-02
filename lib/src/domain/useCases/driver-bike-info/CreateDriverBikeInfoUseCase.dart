import 'package:rabbit_flutter/src/data/repository/DriverBikeInfoRepository.dart';
import 'package:rabbit_flutter/src/domain/models/DriverBikeInfo.dart';

class CreateDriverBikeInfoUseCase {

  DriverBikeInfoRepository driverBikeInfoRepository;
  CreateDriverBikeInfoUseCase(this.driverBikeInfoRepository);
  run(DriverBikeInfo driverBikeInfo) => driverBikeInfoRepository.create(driverBikeInfo);
}