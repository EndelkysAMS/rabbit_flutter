import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultIconBack.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextField.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:rabbit_flutter/src/presentation/utils/GalleryOrPhotoDialog.dart';

class ProfileUpdateContent extends StatelessWidget {

  final User? user;
  final ProfileUpdateState state;

  const ProfileUpdateContent(this.state, this.user,);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.formKey,
      child: Stack(
        children: [
          Column(
            children: [
              _headerProfile(context),
              const Spacer(),
              _actionProfile(context, 'Actualizar Usuario', Icons.check),
              const SizedBox(height: 35),
            ],
          ),
          _cardUserInfo(context),
          DefaultIconBack(
            margin: const EdgeInsets.only(top: 60, left: 30),
          ),
        ],
      ),
    );
  }

  Widget _imageUser(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GalleryOrPhotoDialog(
          context,
          () => context.read<ProfileUpdateBloc>().add(PickImage()),
          () => context.read<ProfileUpdateBloc>().add(TakePhoto()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: SizedBox(
          width: 115,
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipOval(
              child: state.image != null
                  ? Image.file(state.image!, fit: BoxFit.cover)
                  : user?.image != null
                      ? FadeInImage.assetNetwork(
                          placeholder: 'assets/img/user_image.jpg',
                          image: user!.image!,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(seconds: 1),
                        )
                      : Image.asset('assets/img/user_image.jpg'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 35, right: 35, top: 150),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
          children: [
            _imageUser(context),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
              child: DefaultTextField(
                hintText: 'Nombre',
                icon: Icons.person,
                backgroundColor: Colors.grey[200]!,
                initialValue: state.name.value.isNotEmpty ? state.name.value : user?.name,
                onChanged: (text) {
                  context.read<ProfileUpdateBloc>().add(
                    NameChanged(name: BlocFormItem(value: text)),
                  );
                },
                validator: (value) => state.name.error,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
              child: DefaultTextField(
                hintText: 'Apellido',
                icon: Icons.person_outline,
                backgroundColor: Colors.grey[200]!,
                initialValue: state.lastname.value.isNotEmpty ? state.lastname.value : user?.lastname,
                onChanged: (text) {
                  context.read<ProfileUpdateBloc>().add(
                    LastNameChanged(lastname: BlocFormItem(value: text)),
                  );
                },
                validator: (value) => state.lastname.error,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
              child: DefaultTextField(
                hintText: 'Telefono',
                icon: Icons.phone,
                backgroundColor: Colors.grey[200]!,
                initialValue: state.phone.value.isNotEmpty ? state.phone.value : user?.phone,
                onChanged: (text) {
                  context.read<ProfileUpdateBloc>().add(
                    PhoneChanged(phone: BlocFormItem(value: text)),
                  );
                },
                validator: (value) => state.phone.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionProfile(BuildContext context, String option, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (state.formKey?.currentState != null) {
          if (state.formKey!.currentState!.validate()) {
            context.read<ProfileUpdateBloc>().add(FormSubmit());
          }
        } else {
          context.read<ProfileUpdateBloc>().add(FormSubmit());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 15),
        child: ListTile(
          title: Text(
            option,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFF8000),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _headerProfile(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 70),
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: Color(0xFFFF8000)),
      child: const Text(
        'Perfil de Usuario',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
    );
  }
}