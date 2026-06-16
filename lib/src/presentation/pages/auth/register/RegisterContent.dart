import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultButton.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextFieldOutlined.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class RegisterContent extends StatelessWidget {
  final RegisterState state;

  const RegisterContent({super.key, required this.state});

  static const _fieldPadding = EdgeInsets.symmetric(horizontal: 50);
  static const _fieldGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/man-woman-riding-scooter.jpg',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: _fieldPadding,
                  child: Column(
                    children: [
                      DefaultTextFieldOutlined(
                        hintText: "Nombre",
                        icon: Icons.person_outline,
                        bottomMargin: _fieldGap,
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(
                                NameChange(name: BlocFormItem(value: text)),
                              );
                        },
                        validator: (value) {
                          return state.name.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        hintText: "Apellido",
                        icon: Icons.person_2_outlined,
                        bottomMargin: _fieldGap,
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(
                                LastnameChange(
                                  lastname: BlocFormItem(value: text),
                                ),
                              );
                        },
                        validator: (value) {
                          return state.lastname.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        hintText: "Email",
                        icon: Icons.email_outlined,
                        bottomMargin: _fieldGap,
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(
                                EmailChange(email: BlocFormItem(value: text)),
                              );
                        },
                        validator: (value) {
                          return state.email.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        hintText: "Teléfono",
                        icon: Icons.phone_outlined,
                        bottomMargin: _fieldGap,
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(
                                PhoneChange(phone: BlocFormItem(value: text)),
                              );
                        },
                        validator: (value) {
                          return state.phone.error;
                        },
                      ),
                      DefaultTextFieldOutlined(
                        hintText: "Contraseña",
                        icon: Icons.lock_outline,
                        bottomMargin: _fieldGap,
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(
                                PasswordChanged(
                                  password: BlocFormItem(value: text),
                                ),
                              );
                        },
                        validator: (value) {
                          return state.password.error;
                        },
                        obscureText: true,
                      ),
                      DefaultTextFieldOutlined(
                        hintText: "Confirmar Contraseña",
                        icon: Icons.lock_outline,
                        bottomMargin: 0,
                        onChanged: (text) {
                          context.read<RegisterBloc>().add(
                                ConfirmPasswordChanged(
                                  confirmpassword: BlocFormItem(value: text),
                                ),
                              );
                        },
                        validator: (value) {
                          return state.confirmpassword.error;
                        },
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: _fieldPadding,
                  child: Center(
                    child: DefaultButton(
                      text: "Crear usuario",
                      onPressed: () {
                        if (state.formKey!.currentState!.validate()) {
                          context.read<RegisterBloc>().add(FormSubmit());
                          context.read<RegisterBloc>().add(FormReset());
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 1,
                      color: Colors.black26,
                    ),
                    const Text(
                      " O ",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 1,
                      color: Colors.black26,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "login",
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "¿Ya tienes una cuenta? ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "login",
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          color: Color(0xFFFF8C00),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
