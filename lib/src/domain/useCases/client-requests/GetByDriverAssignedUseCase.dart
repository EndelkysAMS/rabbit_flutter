import 'package:rabbit_flutter/src/domain/repository/ClientRequestsRepository.dart';

class GetByDriverAssignedUseCase {

  ClientRequestsRepository clientRequestsRepository;

  GetByDriverAssignedUseCase(this.clientRequestsRepository);

  run(int idDriver) => clientRequestsRepository.getByDriverAssigned(idDriver);

}