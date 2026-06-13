import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';

class DeactivateAdminLineaDriverUseCase {
  final AdminLineaRepository adminLineaRepository;

  DeactivateAdminLineaDriverUseCase(this.adminLineaRepository);

  run(int idDriver) => adminLineaRepository.deactivateDriver(idDriver);
}

