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

  @override
  Widget build(BuildContext context) {  
    return Form(
      key: state.formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/img/man-woman-riding-scooter.jpg',
                    width: 130,
                    height: 130,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    child: DefaultTextFieldOutlined(
                      hintText: "Nombre",
                      icon: Icons.person_outline,
                      onChanged: (text){
                        context.read<RegisterBloc>().add(NameChange(name: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.name.error;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    child: DefaultTextFieldOutlined(
                      hintText: "Apellido",
                      icon: Icons.person_2_outlined,
                      onChanged: (text){
                        context.read<RegisterBloc>().add(LastnameChange(lastname: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.lastname.error;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    child: DefaultTextFieldOutlined(
                      hintText: "Email",
                      icon: Icons.email_outlined,
                      onChanged: (text){
                        context.read<RegisterBloc>().add(EmailChange(email: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.email.error;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    child: DefaultTextFieldOutlined(
                      hintText: "Teléfono",
                      icon: Icons.phone_outlined,
                      onChanged: (text){
                        context.read<RegisterBloc>().add(PhoneChange(phone: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.phone.error;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    child: DefaultTextFieldOutlined(
                      hintText: "Contraseña",
                      icon: Icons.lock_outline,
                      onChanged: (text){
                        context.read<RegisterBloc>().add(PasswordChanged(password: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.password.error;
                      },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    child: DefaultTextFieldOutlined(
                      hintText: "Confirmar Contraseña",
                      icon: Icons.lock_outline,
                      onChanged: (text){
                        context.read<RegisterBloc>().add(ConfirmPasswordChanged(confirmpassword: BlocFormItem(value: text)));
                      },
                      validator: (value) {
                        return state.confirmpassword.error;
                      },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                    child: DefaultButton(
                      text: "Crear usuario",
                      onPressed: () {
                        if(state.formKey!.currentState!.validate()){
                           context.read<RegisterBloc>().add(FormSubmit());   
                           context.read<RegisterBloc>().add(FormReset());   
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 25,
                          height: 1,
                          color: Colors.black26,
                        ),
                        const Text(
                          " O ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                          ),
                        ),
                        Container(
                          width: 25,
                          height: 1,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
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
                            fontSize: 16,
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
                            fontSize: 16,
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