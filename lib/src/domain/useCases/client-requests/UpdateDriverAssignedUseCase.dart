import 'package:rabbit_flutter/src/domain/repository/ClientRequestsRepository.dart';

class UpdateDriverAssignedUseCase {

  ClientRequestsRepository clientRequestsRepository;

  UpdateDriverAssignedUseCase(this.clientRequestsRepository);

  run(int idClientRequest, int idDriver, double fareAssigned) => clientRequestsRepository.updateDriverAssigned(idClientRequest, idDriver, fareAssigned);

}