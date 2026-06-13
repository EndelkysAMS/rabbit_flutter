import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultButton.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextField.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class LoginContent extends StatelessWidget {
  final LoginState state;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginContent(
    this.state, {
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
                    controller: emailController,
                    onChanged: (String text) {
                      context
                          .read<LoginBloc>()
                          .add(EmailChanged(email: BlocFormItem(value: text)));
                    },
                    validator: (value) {
                      return state.email.error;
                    },
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),
                  DefaultTextField(
                    controller: passwordController,
                    onChanged: (String text) {
                      context.read<LoginBloc>().add(
                          PasswordChanged(password: BlocFormItem(value: text)));
                    },
                    validator: (value) {
                      return state.password.error;
                    },
                    hintText: "Contraseña",
                    icon: Icons.lock_outline,
                    obscureText: !state.showPassword,
                    suffixIcon: state.showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: () {
                      context.read<LoginBloc>().add(TogglePasswordVisibility());
                    },
                  ),
                  const SizedBox(height: 16),
                  DefaultButton(
                    text: "Login",
                    onPressed: () {
                      final email = emailController.text.trim();
                      final password = passwordController.text;
                      if (email.isEmpty) {
                        Fluttertoast.showToast(msg: 'Ingresa el email');
                        context.read<LoginBloc>().add(
                              EmailChanged(
                                email: BlocFormItem(value: email),
                              ),
                            );
                        return;
                      }
                      if (password.isEmpty) {
                        Fluttertoast.showToast(msg: 'Ingresa la contraseña');
                        context.read<LoginBloc>().add(
                              PasswordChanged(
                                password: BlocFormItem(value: password),
                              ),
                            );
                        return;
                      }
                      if (password.length < 6) {
                        Fluttertoast.showToast(msg: 'Mínimo 6 caracteres');
                        context.read<LoginBloc>().add(
                              PasswordChanged(
                                password: BlocFormItem(value: password),
                              ),
                            );
                        return;
                      }
                      context.read<LoginBloc>().add(
                            FormSubmit(
                              email: email,
                              password: password,
                            ),
                          );
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
