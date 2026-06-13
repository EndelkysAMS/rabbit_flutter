import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';

class GetAdminLineaDriversUseCase {
  final AdminLineaRepository adminLineaRepository;

  GetAdminLineaDriversUseCase(this.adminLineaRepository);

  run({bool? isActive}) =>
      adminLineaRepository.getDrivers(isActive: isActive);
}

