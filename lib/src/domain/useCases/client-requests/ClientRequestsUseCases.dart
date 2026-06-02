import 'package:rabbit_flutter/src/domain/useCases/client-requests/CreateClientRequestUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/GetByClientAssignedUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/GetByClientRequestUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/GetByDriverAssignedUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/GetNearbyTripRequestUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/GetTimeAndDistanceUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/UpdateClientRatingUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/UpdateDriverAssignedUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/UpdateDriverRatingUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/UpdateStatusClientRequestUseCase.dart';

class ClientRequestsUseCases {

  CreateClientRequestUseCase createClientRequest;
  GetTimeAndDistanceUseCase getTimeAndDistance;
  GetNearbyTripRequestUseCase getNearbyTripRequest;
  UpdateDriverAssignedUseCase updateDriverAssigned;
  GetByClientRequestUseCase getByClientRequest;
  UpdateStatusClientRequestUseCase updateStatusClientRequest;
  UpdateClientRatingUseCase updateClientRating;
  UpdateDriverRatingUseCase updateDriverRating;
  GetByClientAssignedUseCase getByClientAssigned;
  GetByDriverAssignedUseCase getByDriverAssigned;

  ClientRequestsUseCases({
    required this.createClientRequest,
    required this.getTimeAndDistance,
    required this.getNearbyTripRequest,
    required this.updateDriverAssigned,
    required this.getByClientRequest,
    required this.updateStatusClientRequest,
    required this.updateClientRating,
    required this.updateDriverRating,
    required this.getByClientAssigned,
    required this.getByDriverAssigned,
  });

}