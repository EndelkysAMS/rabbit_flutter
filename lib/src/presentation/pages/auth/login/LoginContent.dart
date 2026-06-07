import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultButton.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextField.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class LoginContent extends StatelessWidget {
  
  final LoginState state;

  const LoginContent(this.state);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/img/Logo.png',
                    width: 250,
                    height: 250,
                  ),
                  DefaultTextField(
                    onChanged: ( String text) {
                      context.read<LoginBloc>().add(EmailChanged(email: BlocFormItem(value: text)));
                    },
                    validator: (value) {
                     return state.email.error;
                    },
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),
                  DefaultTextField(
                    onChanged: ( String text) {
                      context.read<LoginBloc>().add(PasswordChanged(password: BlocFormItem(value: text)));
                    },
                    validator: (value) {
                     return state.password.error;
                    },
                    hintText: "Contraseña",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DefaultButton(
                    text: "Login",
                    onPressed: () {
                      if(state.formKey!.currentState!.validate()) {
                      context.read<LoginBloc>().add(FormSubmit());
                      }
                      else {
                        print('El formulario no es valido');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.black26)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'O',
                          style: TextStyle(color: Colors.black38, fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.black26)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "register");
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Color(0xFFFF8C00),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}