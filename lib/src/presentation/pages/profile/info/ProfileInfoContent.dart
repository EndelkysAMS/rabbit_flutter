import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoEvent.dart';

class ProfileInfoContent extends StatelessWidget {
  final User? user;

  const ProfileInfoContent(this.user);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _headerProfile(context),
            Spacer(),
            _actionProfile('Editar Perfil', Icons.edit, () {
              Navigator.pushNamed(context, 'profile/update', arguments: user);
            }),
            _actionProfile('Cerrar Sesión', Icons.settings_power, () {
              context.read<ProfileInfoBloc>().add(LogoutProfile());
            }),
            SizedBox(
              height: 35,
            )
          ],
        ),
        _cardUserInfo(context)
      ],
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 160),
      width: MediaQuery.of(context).size.width,
      height: 250,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: 115,
              margin: EdgeInsets.only(top: 15, bottom: 15),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipOval(
                  child: user != null &&
                          user!.image != null &&
                          user!.image!.isNotEmpty
                      ? FadeInImage.assetNetwork(
                          placeholder: 'assets/img/user_image.jpg',
                          image: user!.image!,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration(seconds: 1),
                        )
                      : Image.asset(
                          'assets/img/user_image.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Text(
              '${user?.name ?? ''} ${user?.lastname ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              user?.phone ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionProfile(String option, IconData icon, Function() function) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 15),
        child: ListTile(
          title: Text(
            option,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Color(0xFFFF8000),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerProfile(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 40),
      height: MediaQuery.of(context).size.height * 0.33,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Color(0xFFFF8000),
      ),
      child: const Text(
        'Perfil de Usuario',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
