import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';

import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';

import 'package:rabbit_flutter/main.dart';

import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';

import 'package:rabbit_flutter/src/domain/models/Role.dart';

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

  bool _didClearForm = false;



  static const _knownRoutes = {

    'login',

    'register',

    'roles',

    'admin/home',

    'admin/drivers/create',

    'admin/drivers/list',

    'admin/drivers/delete',

    'admin/profile',

    'admin/plan',

    'super/home',

    'super/lines',

    'super/lines/detail',

    'client/home',

    'driver/home',

    'client/map/booking',

    'profile/update',

    'client/driver/offers',

    'client/map/trip',

    'driver/map/trip',

    'driver/rating/trip',

    'driver/client/request',

    'client/rating/trip',

  };



  @override

  void initState() {

    super.initState();

    _isNavigating = false;

    _emailController.clear();

    _passwordController.clear();

  }



  @override

  void didChangeDependencies() {

    super.didChangeDependencies();

    if (!_didClearForm) {

      _didClearForm = true;

      context.read<LoginBloc>().add(ClearLoginForm());

    }

  }



  @override

  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();

  }



  String _roleText(Role role, String Function(String) pick) {

    return pick(role.id) +

        pick(role.name) +

        pick(role.route);

  }



  bool _isRabbitSuperRole(Role role) {
    return role.id == 'RABBIT_SUPER' ||
        role.name.toUpperCase().contains('RABBIT SUPER') ||
        role.route == 'super/home';
  }

  bool _isAdminLineaRole(Role role) {
    if (_isRabbitSuperRole(role)) return false;

    final text = _roleText(role, (v) => v.toLowerCase());

    return role.id == '3' ||

        text.contains('admin') ||

        text.contains('linea') ||

        role.route == 'admin/home';

  }



  bool _isDriverRole(Role role) {

    final name = role.name.toUpperCase();

    return role.route == 'driver/home' ||

        name.contains('CONDUCTOR') ||

        name.contains('DRIVER');

  }



  bool _isClientRole(Role role) {

    final name = role.name.toUpperCase();

    return role.route == 'client/home' ||

        name.contains('CLIENTE') ||

        name.contains('CLIENT');

  }



  String _normalizeRoute(String route) {

    var normalized = route.trim();

    if (normalized.startsWith('/')) {

      normalized = normalized.substring(1);

    }

    return _knownRoutes.contains(normalized) ? normalized : '';

  }



  String _resolveTargetRoute(List<Role> roles) {

    if (roles.any(_isRabbitSuperRole)) return 'super/home';

    if (roles.any(_isAdminLineaRole)) return 'admin/home';

    if (roles.length > 1) return 'roles';

    if (roles.length == 1) {

      final role = roles.first;

      if (_isRabbitSuperRole(role)) return 'super/home';

      if (_isAdminLineaRole(role)) return 'admin/home';

      final normalized = _normalizeRoute(role.route);

      if (normalized.isNotEmpty) return normalized;

      if (_isDriverRole(role)) return 'driver/home';

      if (_isClientRole(role)) return 'client/home';

    }

    return 'client/home';

  }



  void _handleSuccess(BuildContext context, AuthResponse authResponse) {

    try {

      debugPrint('[LoginPage] navigating with user=${authResponse.user.id} '

          'roles=${authResponse.user.roles?.map((r) => r.route).toList()}');



      context

          .read<LoginBloc>()

          .add(SaveUserSession(authResponse: authResponse));

      if (authResponse.user.id != null) {

        context.read<LoginBloc>().add(

              UpdateNotificationToken(id: authResponse.user.id!),

            );

      }



      final target = _resolveTargetRoute(authResponse.user.roles ?? []);

      debugPrint('[LoginPage] target route=$target');



      final navigator = navigatorKey.currentState ?? Navigator.of(context);

      navigator.pushNamedAndRemoveUntil(target, (route) => false);



      context.read<BlocSocketIO>().add(ConnectSocketIO());

      context.read<BlocSocketIO>().add(ListenDriverAssignedSocketIO());

    } catch (e, stack) {

      _isNavigating = false;

      debugPrint('[LoginPage] navigation error: $e\n$stack');

      Fluttertoast.showToast(

        msg: 'No se pudo entrar: $e',

        toastLength: Toast.LENGTH_LONG,

      );

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: BlocListener<LoginBloc, LoginState>(

        listenWhen: (previous, current) =>

            previous.response != current.response,

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


