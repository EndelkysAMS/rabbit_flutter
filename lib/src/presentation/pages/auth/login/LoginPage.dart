import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/LoginContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/auth/login/bloc/LoginState.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _isNavigating = false;
    _emailController.clear();
    _passwordController.clear();
    // Reset the bloc to a clean state every time we land on the login screen,
    // so a previous Success/Error never leaks into a new login session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoginBloc>().add(ClearLoginForm());
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSuccess(BuildContext context, AuthResponse authResponse) {
    debugPrint('[LoginPage] navigating with user=${authResponse.user.id} '
        'roles=${authResponse.user.roles?.map((r) => r.route).toList()}');

    context.read<LoginBloc>().add(SaveUserSession(authResponse: authResponse));
    if (authResponse.user.id != null) {
      context
          .read<LoginBloc>()
          .add(UpdateNotificationToken(id: authResponse.user.id!));
    }
    context.read<BlocSocketIO>().add(ConnectSocketIO());
    context.read<BlocSocketIO>().add(ListenDriverAssignedSocketIO());

    final roles = authResponse.user.roles ?? [];
    final hasAdminLineaRole = roles.any((role) {
      final roleId = role.id.toLowerCase();
      final roleName = role.name.toLowerCase();
      final roleRoute = role.route.toLowerCase();
      return roleId == '3' ||
          roleId.contains('admin') ||
          roleName.contains('admin') ||
          roleName.contains('linea') ||
          roleRoute == 'admin/home' ||
          roleRoute.contains('admin');
    });

    String target;
    if (hasAdminLineaRole) {
      target = 'admin/home';
    } else if (roles.length == 1) {
      final singleRoute = roles.first.route;
      target = singleRoute.isNotEmpty ? singleRoute : 'client/home';
    } else if (roles.length > 1) {
      target = 'roles';
    } else {
      target = 'client/home';
    }

    Navigator.pushNamedAndRemoveUntil(context, target, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) => previous.response != current.response,
        listener: (context, state) {
          final response = state.response;
          debugPrint(
              '[LoginPage] listener response=${response.runtimeType} navigating=$_isNavigating');
          if (response is ErrorData) {
            _isNavigating = false;
            Fluttertoast.showToast(
                msg: response.message, toastLength: Toast.LENGTH_SHORT);
            return;
          }
          if (response is Success && !_isNavigating) {
            _isNavigating = true;
            _handleSuccess(context, response.data as AuthResponse);
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) =>
              previous.response != current.response ||
              previous.showPassword != current.showPassword,
          builder: (context, state) {
            final response = state.response;
            if (response is Loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return LoginContent(
              state,
              emailController: _emailController,
              passwordController: _passwordController,
              formKey: _formKey,
            );
          },
        ),
      ),
    );
  }
}
