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
    final minHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  _headerProfile(context),
                  const SizedBox(height: 110),
                  _actionProfile('Editar Perfil', Icons.edit, () {
                    Navigator.pushNamed(
                        context, 'profile/update', arguments: user);
                  }),
                  _actionProfile('Cerrar Sesión', Icons.settings_power, () {
                    context.read<ProfileInfoBloc>().add(LogoutProfile());
                  }, isFirst: false),
                  const SizedBox(height: 35),
                ],
              ),
              _cardUserInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 132),
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              user?.email ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            Text(
              user?.phone ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionProfile(
    String option,
    IconData icon,
    Function() function, {
    bool isFirst = true,
  }) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: isFirst ? 10 : 4),
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            option,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Color(0xFFFF8000),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
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
