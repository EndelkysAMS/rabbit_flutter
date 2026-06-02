import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

abstract  class RegisterEvent {}

class RegisterInitEvent extends RegisterEvent {}

class NameChange extends RegisterEvent {
  final BlocFormItem name;
  NameChange({ required this.name });
}

class LastnameChange extends RegisterEvent {
  final BlocFormItem lastname;
  LastnameChange({ required this.lastname});
}

class EmailChange extends RegisterEvent {
  final BlocFormItem email;
  EmailChange({ required this.email });
}

class PhoneChange extends RegisterEvent {
  final BlocFormItem phone;
  PhoneChange({ required this.phone });
}

class PasswordChanged extends RegisterEvent {
  final BlocFormItem password;
  PasswordChanged({ required this.password });
}

class ConfirmPasswordChanged extends RegisterEvent {
  final BlocFormItem confirmpassword;
  ConfirmPasswordChanged({ required this.confirmpassword });
}

class SaveUserSession extends RegisterEvent {
  final AuthResponse authResponse;
  SaveUserSession({ required this.authResponse });
}





class FormSubmit extends RegisterEvent {}
class FormReset extends  RegisterEvent {}