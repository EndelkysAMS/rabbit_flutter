import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';

class DeleteAdminLineaDriverUseCase {
  final AdminLineaRepository adminLineaRepository;

  DeleteAdminLineaDriverUseCase(this.adminLineaRepository);

  run(int idDriver) => adminLineaRepository.deleteDriver(idDriver);
}
