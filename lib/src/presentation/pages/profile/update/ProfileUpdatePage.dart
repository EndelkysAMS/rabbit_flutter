import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/ProfileUpdateContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateState.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  User? user;

  @override
  void initState() {
    // PRIMER EVENTO EN DISPARARSE - UNA SOLA VEZ
    // TODO: implement initState
    super.initState();
    print('METODO INIT STATE');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print('METODO INIT STATE BINDING');
      context.read<ProfileUpdateBloc>().add(ProfileUpdateInitEvent(user: user));
    });
  }

  @override
  Widget build(BuildContext context) {
    // SEGUNDO - CTRL + S
    print('METODO BUILD');
    user = ModalRoute.of(context)?.settings.arguments as User;
    return Scaffold(
      body: BlocListener<ProfileUpdateBloc, ProfileUpdateState>(
        listenWhen: (previous, current) =>
            previous.response != current.response,
        listener: (context, state) {
          final response = state.response;
          if (response is ErrorData) {
            Fluttertoast.showToast(
                msg: response.message, toastLength: Toast.LENGTH_LONG);
            context
                .read<ProfileUpdateBloc>()
                .add(ClearProfileUpdateResponse());
          } else if (response is Success) {
            final User updatedUser = response.data as User;
            Fluttertoast.showToast(
                msg: 'Actualizacion exitosa', toastLength: Toast.LENGTH_LONG);
            context
                .read<ProfileUpdateBloc>()
                .add(UpdateUserSession(user: updatedUser));
            context
                .read<ProfileUpdateBloc>()
                .add(ClearProfileUpdateResponse());
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                context.read<ProfileInfoBloc>().add(GetUserInfo());
              }
            });
          }
        },
        child: BlocBuilder<ProfileUpdateBloc, ProfileUpdateState>(
          builder: (context, state) {
            final response = state.response;
            if (response is Loading) {
              return Stack(
                children: [
                  ProfileUpdateContent(state, user),
                  Center(child: CircularProgressIndicator())
                ],
              );
            }
            return ProfileUpdateContent(state, user);
          },
        ),
      ),
    );
  }
}