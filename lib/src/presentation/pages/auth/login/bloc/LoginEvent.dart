import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

abstract class LoginEvent {}

class LoginInitEvent extends LoginEvent {}

class EmailChanged extends LoginEvent {
  final BlocFormItem email;
  EmailChanged({required this.email});
}

class PasswordChanged extends LoginEvent {
  final BlocFormItem password;
  PasswordChanged({required this.password});
}

class SaveUserSession extends LoginEvent {
  final AuthResponse authResponse;
  SaveUserSession({required this.authResponse});
}

class UpdateNotificationToken extends LoginEvent {
  final int id;
  final String? token;
  UpdateNotificationToken({required this.id, this.token});
}

class FormSubmit extends LoginEvent {
  final String? email;
  final String? password;

  FormSubmit({this.email, this.password});
}

class TogglePasswordVisibility extends LoginEvent {}

class ClearLoginForm extends LoginEvent {}
