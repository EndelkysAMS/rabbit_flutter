import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/FirebasePushNotifications.dart';
import 'package:rabbit_flutter/src/domain/useCases/users/UsersUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginState.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthUseCases authUseCases;
  UsersUseCases usersUseCases;

  LoginBloc(this.authUseCases, this.usersUseCases) : super(const LoginState()) {
    on<LoginInitEvent>((event, emit) async {
      // Keep login screen explicit; do not auto-navigate from cached session.
      emit(const LoginState());
    });

    on<EmailChanged>((event, emit) {
      emit(state.copyWith(
        email: BlocFormItem(
            value: event.email.value,
            error: event.email.value.isEmpty ? 'Ingresa el email' : null),
        response: null,
      ));
    });

    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(
        password: BlocFormItem(
            value: event.password.value,
            error: event.password.value.isEmpty
                ? 'Ingresa el password'
                : event.password.value.length < 6
                    ? 'Minimo 6 caracteres'
                    : null),
        response: null,
      ));
    });

    on<TogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(showPassword: !state.showPassword, response: null));
    });

    on<ClearLoginForm>((event, emit) {
      emit(const LoginState());
    });

    on<FormSubmit>((event, emit) async {
      final email = event.email ?? state.email.value;
      final password = event.password ?? state.password.value;
      emit(state.copyWith(response: Loading()));
      Resource response = await authUseCases.login.run(email, password);
      emit(state.copyWith(response: response));
    });

    on<UpdateNotificationToken>((event, emit) async {
      try {
        String? token = event.token;
        token ??= await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await usersUseCases.updateNotificationToken.run(event.id, token);
        }
      } catch (e) {
        print('ERROR ACTUALIZANDO TOKEN: $e');
      }
    });

    on<SaveUserSession>((event, emit) async {
      await authUseCases.saveUserSession.run(event.authResponse);
      final id = event.authResponse.user.id;
      if (id != null) {
        await registerFcmTokenRefresh((token) async {
          add(UpdateNotificationToken(id: id, token: token));
        });
      }
    });
  }
}
