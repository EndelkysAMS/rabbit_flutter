import 'package:equatable/equatable.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

const Object _unset = Object();

class LoginState extends Equatable {
  final BlocFormItem email;
  final BlocFormItem password;
  final bool showPassword;
  final Resource? response;

  const LoginState({
    this.email = const BlocFormItem(error: 'Ingresa el email'),
    this.password = const BlocFormItem(error: 'Ingresa el password'),
    this.showPassword = false,
    this.response,
  });

  LoginState copyWith({
    BlocFormItem? email,
    BlocFormItem? password,
    bool? showPassword,
    Object? response = _unset,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
      response:
          identical(response, _unset) ? this.response : response as Resource?,
    );
  }

  @override
  List<Object?> get props => [email, password, showPassword, response];
}
