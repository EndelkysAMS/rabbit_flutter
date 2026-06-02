import 'package:rabbit_flutter/src/domain/repository/SocketRepository.dart';

class ConnectSocketUseCase {

 SocketRepository socketRepository;

 ConnectSocketUseCase(this.socketRepository);

 run() => socketRepository.connect();

}