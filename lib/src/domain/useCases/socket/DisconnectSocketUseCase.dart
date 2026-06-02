import 'package:rabbit_flutter/src/domain/repository/SocketRepository.dart';

class DisconnectSocketUseCase {

 SocketRepository socketRepository;

 DisconnectSocketUseCase(this.socketRepository);

 run() => socketRepository.disconnect();

}