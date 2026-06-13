import 'package:rabbit_flutter/src/domain/models/AdminLineaCreateDriver.dart';
import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';

class CreateAdminLineaDriverUseCase {
  final AdminLineaRepository adminLineaRepository;

  CreateAdminLineaDriverUseCase(this.adminLineaRepository);

  run(AdminLineaCreateDriver createDriver) =>
      adminLineaRepository.createDriver(createDriver);
}

