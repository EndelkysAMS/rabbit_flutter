import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';

class ReactivateAdminLineaDriverUseCase {
  final AdminLineaRepository adminLineaRepository;

  ReactivateAdminLineaDriverUseCase(this.adminLineaRepository);

  run(int idDriver) => adminLineaRepository.reactivateDriver(idDriver);
}
