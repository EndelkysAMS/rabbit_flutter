import 'package:rabbit_flutter/src/domain/repository/UsersRepository.dart';

class UpdateNotificationTokenUseCase {

  UsersRepository usersRepository;

  UpdateNotificationTokenUseCase(this.usersRepository);

  run(int id, String notificationToken) => usersRepository.updateNotificationToken(id, notificationToken);

}