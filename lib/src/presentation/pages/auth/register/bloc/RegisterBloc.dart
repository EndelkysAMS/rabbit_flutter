import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {

  AuthUseCases authUseCases;
  final formKey = GlobalKey<FormState>();
  
  RegisterBloc(this.authUseCases) : super(RegisterState()) {
    on<RegisterInitEvent>((event, emit) {
      emit(state.copyWith(formKey: formKey ));
    });

    on<SaveUserSession>((event, emit)  async{
       await  authUseCases.saveUserSession.run(event.authResponse);
    });
    

  on<NameChange>((event, emit) {
    emit(
      state.copyWith(
        name: BlocFormItem(
          value: event.name.value,
          error: event.name.value.isEmpty ? 'Ingresa tus nombres' : null
        ),
        formKey: formKey
      )
    );
  });
  
  on<LastnameChange>((event, emit) {
    emit(
      state.copyWith(
        lastname: BlocFormItem(
          value: event.lastname.value,
          error: event.lastname.value.isEmpty ? 'Ingresa tus apellidos' : null
        ),
        formKey: formKey
      )
    );
  });
  
  on<EmailChange>((event, emit) {
    emit(
      state.copyWith(
        email: BlocFormItem(
          value: event.email.value,
          error: event.email.value.isEmpty ? 'Ingresa tus nombres' : null
        ),
        formKey: formKey
      )
    );
  });

  on<PhoneChange>((event, emit) {
    emit(
      state.copyWith(
        phone: BlocFormItem(
          value: event.phone.value,
          error: event.phone.value.isEmpty ? 'Ingresa el teléfono' : null
        ),
        formKey: formKey
      )
    );
  });
  
on<PasswordChanged>((event, emit) {
    emit(
      state.copyWith(
        password: BlocFormItem(
          value: event.password.value,
          error: event.password.value.isEmpty 
          ? 'Ingresa la contraseña' 
          :  event.password.value.length < 6 
            ? 'Más de 6 caracteres'
            : null
        ),
        formKey: formKey
      )
    );
  });

on<ConfirmPasswordChanged>((event, emit) {
    emit(
      state.copyWith(
        confirmpassword: BlocFormItem(
          value: event.confirmpassword.value,
          error: event.confirmpassword.value.isEmpty 
          ? 'Confirma la contraseña' 
          : event.confirmpassword.value.length < 6
            ? 'Más de 6 caracteres'
            : event.confirmpassword.value != state.password.value
            ? 'Las contraseñas no coinciden'
            : null
        ),
        formKey: formKey
      )
    );
  });

  on<FormSubmit>((event, emit) async{
    print('Name: ${state.name.value}');
    print('LastName: ${state.lastname.value}');
    print('Email: ${state.email.value}');
    print('Phone: ${state.phone.value}');
    print('Password: ${state.password.value}');
    print('ConfirmPassword: ${state.confirmpassword.value}');
    emit(
      state.copyWith(
        response: Loading(),
        formKey: formKey
      )
      );
      Resource response  = await authUseCases.register.run(state.toUser());
      emit(
      state.copyWith(
        response: response,
        formKey: formKey
      )
      );
  });
  
  on<FormReset>((event, emit) {
    state.formKey?.currentState?.reset();
  });

  }
}