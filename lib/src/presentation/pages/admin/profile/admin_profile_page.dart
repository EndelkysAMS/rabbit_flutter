import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rabbit_flutter/src/domain/models/AdminLineaProfile.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_state.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _fieldsInitialized = false;

  static final RegExp _emojiRegExp = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}\u{FE00}-\u{FE0F}\u{1F1E6}-\u{1F1FF}\u{200D}\u{20E3}\u{2122}\u{2139}\u{2934}\u{2935}]',
    unicode: true,
  );

  static final List<TextInputFormatter> _noEmojiFormatters = [
    FilteringTextInputFormatter.deny(_emojiRegExp),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AdminDashboardBloc>().state.adminUser;
      if (user != null) _syncFieldsFromUser(user);
    });
  }

  void _syncFieldsFromUser(dynamic user) {
    _nameCtrl.text = user.name ?? '';
    _phoneCtrl.text = user.phone ?? '';
    _imageCtrl.text = user.image ?? '';
    _fieldsInitialized = true;
  }

  Widget _profileImage() {
    final path = _imageCtrl.text.trim();
    if (path.isNotEmpty && !path.startsWith('http')) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    if (path.isNotEmpty) {
      return FadeInImage.assetNetwork(
        placeholder: 'assets/img/user_image.jpg',
        image: path,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        imageErrorBuilder: (_, __, ___) =>
            Image.asset('assets/img/user_image.jpg', fit: BoxFit.cover),
      );
    }
    return Image.asset('assets/img/user_image.jpg', fit: BoxFit.cover);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _imageCtrl.text = image.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil admin'),
        backgroundColor: const Color(0xFFFF8000),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
        listenWhen: (previous, current) =>
            previous.responseUpdateProfile != current.responseUpdateProfile,
        listener: (context, state) {
          if (state.adminUser != null && !_fieldsInitialized) {
            _syncFieldsFromUser(state.adminUser!);
            setState(() {});
          }

          final response = state.responseUpdateProfile;
          if (response is Success) {
            if (state.adminUser != null) {
              _syncFieldsFromUser(state.adminUser!);
              setState(() {});
            }
            Fluttertoast.showToast(msg: 'Perfil actualizado');
            context
                .read<AdminDashboardBloc>()
                .add(ClearUpdateProfileResponseEvent());
          } else if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message);
            context
                .read<AdminDashboardBloc>()
                .add(ClearUpdateProfileResponseEvent());
          }
        },
        builder: (context, state) {
          if (state.adminUser != null && !_fieldsInitialized) {
            _syncFieldsFromUser(state.adminUser!);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8000),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Perfil de Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: SizedBox(
                            width: 115,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipOval(child: _profileImage()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca la imagen para cambiarla',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameCtrl,
                          inputFormatters: _noEmojiFormatters,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo obligatorio'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo obligatorio'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              final currentLastname =
                                  state.adminUser?.lastname ?? '';
                              context
                                  .read<AdminDashboardBloc>()
                                  .add(UpdateAdminProfileEvent(
                                    profile: AdminLineaProfile(
                                      name: _nameCtrl.text.trim(),
                                      lastname: currentLastname,
                                      phone: _phoneCtrl.text.trim(),
                                      image: _imageCtrl.text.trim().isEmpty
                                          ? null
                                          : _imageCtrl.text.trim(),
                                    ),
                                  ));
                            },
                            child: const Text('Actualizar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
