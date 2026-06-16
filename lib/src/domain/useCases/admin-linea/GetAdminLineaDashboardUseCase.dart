import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';

class GetAdminLineaDashboardUseCase {
  final AdminLineaRepository adminLineaRepository;

  GetAdminLineaDashboardUseCase(this.adminLineaRepository);

  run() => adminLineaRepository.getDashboard();
}
