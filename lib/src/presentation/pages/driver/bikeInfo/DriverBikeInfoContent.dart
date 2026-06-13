import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikeInfoBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikeInfoState.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikoInfoEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextField.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class DriverBikeInfoContent extends StatelessWidget {
  final DriverBikeInfoState state;

  const DriverBikeInfoContent(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: state.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset + 24),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _headerProfile(context),
                _cardUserInfo(context),
              ],
            ),
            _actionProfile(context, 'Actualizar Datos', Icons.check),
          ],
        ),
      ),
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 35,
        right: 35,
        top: MediaQuery.of(context).size.height * 0.14,
      ),
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: DefaultTextField(
                  hintText: 'Marca de la moto',
                  icon: Icons.person,
                  backgroundColor: Colors.grey[200]!,
                  initialValue: state.brand.value,
                  onChanged: (text) {
                    context.read<DriverBikeInfoBloc>().add(
                          BrandChanged(brand: BlocFormItem(value: text)),
                        );
                  },
                  validator: (value) => state.brand.error,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: DefaultTextField(
                  hintText: 'Placa de la moto',
                  icon: Icons.person_outline,
                  backgroundColor: Colors.grey[200]!,
                  initialValue: state.plate.value,
                  keyboardType: TextInputType.phone,
                  onChanged: (text) {
                    context.read<DriverBikeInfoBloc>().add(
                          PlateChanged(plate: BlocFormItem(value: text)),
                        );
                  },
                  validator: (value) => state.plate.error,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: DefaultTextField(
                  hintText: 'Color',
                  icon: Icons.phone,
                  initialValue: state.color.value,
                  backgroundColor: Colors.grey[200]!,
                  onChanged: (text) {
                    context.read<DriverBikeInfoBloc>().add(
                          ColorChanged(color: BlocFormItem(value: text)),
                        );
                  },
                  validator: (value) => state.color.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionProfile(BuildContext context, String option, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (state.formKey!.currentState != null) {
          if (state.formKey!.currentState!.validate()) {
            context.read<DriverBikeInfoBloc>().add(FormSubmit());
          }
        } else {
          context.read<DriverBikeInfoBloc>().add(FormSubmit());
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: MediaQuery.of(context).size.height * 0.18,
      ),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Color(0xFFFF8000),
      ),
      child: const Text(
        'Datos de la Moto',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 19,
        ),
      ),
    );
  }
}
