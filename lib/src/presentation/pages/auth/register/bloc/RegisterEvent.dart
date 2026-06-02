import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

abstract  class RegisterEvent {}

class RegisterInitEvent extends RegisterEvent {}

class NameChange extends RegisterInitEvent {
  final BlocFormItem name;
  NameChange({ required this.name });
}

class LastnameChange extends RegisterInitEvent {
  final BlocFormItem lastname;
  LastnameChange({ required this.lastname});
}

class EmailChange extends RegisterInitEvent {
  final BlocFormItem email;
  EmailChange({ required this.email });
}

class PhoneChange extends RegisterInitEvent {
  final BlocFormItem phone;
  PhoneChange({ required this.phone });
}

class PasswordChanged extends RegisterInitEvent {
  final BlocFormItem password;
  PasswordChanged({ required this.password });
}

class ConfirmPasswordChanged extends RegisterInitEvent {
  final BlocFormItem confirmpassword;
  ConfirmPasswordChanged({ required this.confirmpassword });
}

class SaveUserSession extends RegisterInitEvent {
  final AuthResponse authResponse;
  SaveUserSession({ required this.authResponse });
}





class FormSubmit extends RegisterInitEvent {}
class FormReset extends  RegisterInitEvent {}