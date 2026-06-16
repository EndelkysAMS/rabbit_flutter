import 'package:rabbit_flutter/src/domain/useCases/drivers-position/CreateDriverPositionUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DeleteDriverPositionUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/GetDriverPositionUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/GetNearbyDriversUseCase.dart';

class DriversPositionUseCases {

  CreateDriverPositionUseCase createDriverPosition;
  DeleteDriverPositionUseCase deleteDriverPosition;
  GetDriverPositionUseCase getDriverPosition;
  GetNearbyDriversUseCase getNearbyDrivers;

  DriversPositionUseCases({
    required this.createDriverPosition,
    required this.deleteDriverPosition,
    required this.getDriverPosition,
    required this.getNearbyDrivers,
  });

}