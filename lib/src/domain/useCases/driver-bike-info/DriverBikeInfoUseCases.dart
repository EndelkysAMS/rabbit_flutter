import 'package:rabbit_flutter/src/domain/useCases/driver-bike-info/CreateDriverBikeInfoUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/driver-bike-info/GetDriverBikeInfoUseCase.dart';

class DriverBikeInfoUseCases {

  CreateDriverBikeInfoUseCase createDriverBikeInfo;
  GetDriverBikeInfoUseCase getDriverBikeInfo;

  DriverBikeInfoUseCases({
    required this.createDriverBikeInfo,
    required this.getDriverBikeInfo,
  });

}