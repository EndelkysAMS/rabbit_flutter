import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class RegisterState extends Equatable {

  final BlocFormItem name;
  final BlocFormItem lastname;
  final BlocFormItem email;
  final BlocFormItem phone;
  final BlocFormItem password;
  final BlocFormItem confirmpassword;
  final GlobalKey<FormState>? formKey;
  final Resource? response;
  
  const RegisterState({
    this.name = const BlocFormItem(error: 'Ingresa tu nombre'),
    this.lastname = const BlocFormItem(error: 'Ingresa tu apellido'),
    this.email = const BlocFormItem(error: 'Ingresa  el  email'),
    this.phone = const BlocFormItem(error: 'Ingresa  el teléfono'),
    this.password = const BlocFormItem(error: 'Ingresa la contraseña'),
    this.confirmpassword = const BlocFormItem(error: 'Confirma la contraseña'),
    this.formKey,  
    this.response
  });

  toUser() => User(
    name: name.value,
    lastname: lastname.value,
    email: email.value, 
    phone: phone.value, 
    password: password.value
  );

  RegisterState copyWith({
    BlocFormItem? name,
    BlocFormItem? lastname,
    BlocFormItem? email,
    BlocFormItem? phone,
    BlocFormItem? password,
    BlocFormItem? confirmpassword,
    GlobalKey<FormState>? formKey,
    Resource? response

  }) {
    return RegisterState(
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone, 
      password: password ?? this.password,
      confirmpassword: confirmpassword ?? this.confirmpassword,
      formKey: formKey,
      response:  response
    );
  }
  @override
  List<Object?> get props => [name,lastname,email,phone,password,confirmpassword, response];

}