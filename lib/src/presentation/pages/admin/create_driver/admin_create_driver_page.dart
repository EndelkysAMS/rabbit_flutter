import 'dart:io';



import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';

import 'package:rabbit_flutter/src/domain/models/AdminLineaCreateDriver.dart';

import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_bloc.dart';

import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_event.dart';

import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_state.dart';

class AdminCreateDriverPage extends StatefulWidget {
  const AdminCreateDriverPage({super.key});



  @override

  State<AdminCreateDriverPage> createState() => _AdminCreateDriverPageState();

}



class _AdminCreateDriverPageState extends State<AdminCreateDriverPage> {

  final _nameCtrl = TextEditingController();

  final _lastnameCtrl = TextEditingController();

  final _emailCtrl = TextEditingController();

  final _phoneCtrl = TextEditingController();

  final _passwordCtrl = TextEditingController();

  final _imageCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();



  static final RegExp _emojiRegExp = RegExp(

    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}\u{FE00}-\u{FE0F}\u{1F1E6}-\u{1F1FF}\u{200D}\u{20E3}\u{2122}\u{2139}\u{2934}\u{2935}]',

    unicode: true,

  );



  static final List<TextInputFormatter> _noEmojiFormatters = [

    FilteringTextInputFormatter.deny(_emojiRegExp),

  ];



  @override

  void dispose() {

    _nameCtrl.dispose();

    _lastnameCtrl.dispose();

    _emailCtrl.dispose();

    _phoneCtrl.dispose();

    _passwordCtrl.dispose();

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

        title: const Text('Crear conductor'),

        backgroundColor: const Color(0xFFFF8000),

        foregroundColor: Colors.white,

      ),

      body: BlocListener<AdminDashboardBloc, AdminDashboardState>(
        listenWhen: (previous, current) =>
            previous.responseCreateDriver != current.responseCreateDriver,
        listener: (context, state) {
          final response = state.responseCreateDriver;
          if (response is Success) {
            Fluttertoast.showToast(msg: 'Conductor creado correctamente');
            context
                .read<AdminDashboardBloc>()
                .add(ClearCreateDriverResponseEvent());
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          } else if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message);

            context

                .read<AdminDashboardBloc>()

                .add(ClearCreateDriverResponseEvent());

          }

        },

        child: ListView(

          padding: const EdgeInsets.all(16),

          children: [

            Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: const Color(0xFFFF8000),

                borderRadius: BorderRadius.circular(14),

              ),

              child: const Text(

                'Completa los datos del nuevo conductor',

                style: TextStyle(

                  color: Colors.white,

                  fontWeight: FontWeight.w600,

                ),

              ),

            ),

            const SizedBox(height: 14),

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

                        controller: _lastnameCtrl,

                        inputFormatters: _noEmojiFormatters,

                        decoration: InputDecoration(

                          labelText: 'Apellido',

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

                        controller: _emailCtrl,

                        inputFormatters: _noEmojiFormatters,

                        keyboardType: TextInputType.emailAddress,

                        decoration: InputDecoration(

                          labelText: 'Email',

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

                      const SizedBox(height: 10),

                      TextFormField(

                        controller: _passwordCtrl,

                        inputFormatters: _noEmojiFormatters,

                        obscureText: true,

                        decoration: InputDecoration(

                          labelText: 'Contraseña',

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

                      const SizedBox(height: 14),

                      Align(

                        alignment: Alignment.centerLeft,

                        child: Text(

                          'Imagen',

                          style: TextStyle(

                            fontWeight: FontWeight.w600,

                            color: Colors.grey[800],

                          ),

                        ),

                      ),

                      const SizedBox(height: 8),

                      if (_imageCtrl.text.isNotEmpty)

                        Container(

                          margin: const EdgeInsets.only(bottom: 12),

                          height: 120,

                          width: double.infinity,

                          decoration: BoxDecoration(

                            border: Border.all(color: Colors.black12),

                            borderRadius: BorderRadius.circular(12),

                            image: DecorationImage(

                              image: FileImage(File(_imageCtrl.text)),

                              fit: BoxFit.cover,

                            ),

                          ),

                        ),

                      SizedBox(

                        width: double.infinity,

                        child: OutlinedButton(

                          onPressed: _pickImage,

                          style: OutlinedButton.styleFrom(

                            foregroundColor: const Color(0xFFFF8000),

                            side: const BorderSide(color: Color(0xFFFF8000)),

                            padding: const EdgeInsets.symmetric(vertical: 12),

                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(12),

                            ),

                          ),

                          child: Text(_imageCtrl.text.isEmpty

                              ? 'Seleccionar imagen'

                              : 'Cambiar imagen'),

                        ),

                      ),

                      const SizedBox(height: 16),

                      SizedBox(

                        width: double.infinity,

                        child: ElevatedButton(

                        onPressed: () {

                          if (!_formKey.currentState!.validate()) return;

                          context.read<AdminDashboardBloc>().add(CreateDriverEvent(

                                  createDriver: AdminLineaCreateDriver(

                                name: _nameCtrl.text.trim(),

                                lastname: _lastnameCtrl.text.trim(),

                                email: _emailCtrl.text.trim(),

                                phone: _phoneCtrl.text.trim(),

                                password: _passwordCtrl.text.trim(),

                                image: _imageCtrl.text.trim().isEmpty

                                    ? null

                                    : _imageCtrl.text.trim(),

                              )));

                        },

                        style: ElevatedButton.styleFrom(

                          backgroundColor: const Color(0xFFFF8000),

                          foregroundColor: Colors.white,

                          padding: const EdgeInsets.symmetric(vertical: 14),

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(12),

                          ),

                        ),

                        child: const Text('Crear conductor'),

                      ),

                      ),

                    ],

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}


