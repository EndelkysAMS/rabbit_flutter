import 'package:rabbit_flutter/src/domain/models/AdminLineaProfile.dart';
import 'package:rabbit_flutter/src/domain/repository/AdminLineaRepository.dart';

class UpdateAdminLineaProfileUseCase {
  final AdminLineaRepository adminLineaRepository;

  UpdateAdminLineaProfileUseCase(this.adminLineaRepository);

  run(AdminLineaProfile profile) => adminLineaRepository.updateProfile(profile);
}

