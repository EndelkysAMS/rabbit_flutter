import 'package:rabbit_flutter/src/domain/repository/ClientRequestsRepository.dart';

class UpdateClientRatingUseCase {

  ClientRequestsRepository clientRequestsRepository;

  UpdateClientRatingUseCase(this.clientRequestsRepository);

  run(int idClientRequest, double rating) => clientRequestsRepository.updateClientRating(idClientRequest, rating);

}