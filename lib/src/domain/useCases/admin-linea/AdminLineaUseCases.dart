import 'package:rabbit_flutter/src/domain/useCases/admin-linea/CreateAdminLineaDriverUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/admin-linea/DeactivateAdminLineaDriverUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/admin-linea/DeleteAdminLineaDriverUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/admin-linea/GetAdminLineaDriversUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/admin-linea/UpdateAdminLineaProfileUseCase.dart';

class AdminLineaUseCases {
  final GetAdminLineaDriversUseCase getDrivers;
  final CreateAdminLineaDriverUseCase createDriver;
  final DeactivateAdminLineaDriverUseCase deactivateDriver;
  final DeleteAdminLineaDriverUseCase deleteDriver;
  final UpdateAdminLineaProfileUseCase updateProfile;

  AdminLineaUseCases({
    required this.getDrivers,
    required this.createDriver,
    required this.deactivateDriver,
    required this.deleteDriver,
    required this.updateProfile,
  });
}

