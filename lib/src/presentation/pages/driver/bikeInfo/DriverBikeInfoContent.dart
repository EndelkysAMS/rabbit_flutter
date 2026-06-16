import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikeInfoBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikeInfoState.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikoInfoEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextField.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class DriverBikeInfoContent extends StatefulWidget {
  final DriverBikeInfoState? state;

  const DriverBikeInfoContent({super.key, this.state});

  @override
  State<DriverBikeInfoContent> createState() => _DriverBikeInfoContentState();
}

class _DriverBikeInfoContentState extends State<DriverBikeInfoContent> {
  late final TextEditingController _brandCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _colorCtrl;

  @override
  void initState() {
    super.initState();
    _brandCtrl = TextEditingController(text: widget.state?.brand.value ?? '');
    _plateCtrl = TextEditingController(text: widget.state?.plate.value ?? '');
    _colorCtrl = TextEditingController(text: widget.state?.color.value ?? '');
  }

  @override
  void didUpdateWidget(covariant DriverBikeInfoContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final state = widget.state;
    if (state == null) return;

    if (oldWidget.state?.isInitialized != true && state.isInitialized) {
      _brandCtrl.text = state.brand.value;
      _plateCtrl.text = state.plate.value;
      _colorCtrl.text = state.color.value;
    }
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: state?.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset + 24),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _headerProfile(context),
                if (state != null) _cardUserInfo(context, state),
              ],
            ),
            if (state != null) _actionProfile(context, state),
          ],
        ),
      ),
    );
  }

  Widget _cardUserInfo(BuildContext context, DriverBikeInfoState state) {
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
                  controller: _brandCtrl,
                  hintText: 'Marca de la moto',
                  icon: Icons.two_wheeler,
                  backgroundColor: Colors.grey[200]!,
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
                  controller: _plateCtrl,
                  hintText: 'Placa de la moto',
                  icon: Icons.pin,
                  backgroundColor: Colors.grey[200]!,
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
                  controller: _colorCtrl,
                  hintText: 'Color',
                  icon: Icons.palette_outlined,
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

  Widget _actionProfile(BuildContext context, DriverBikeInfoState state) {
    return GestureDetector(
      onTap: () {
        if (state.formKey?.currentState?.validate() ?? false) {
          context.read<DriverBikeInfoBloc>().add(FormSubmit());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 15),
        child: ListTile(
          title: const Text(
            'Actualizar Datos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFF8000),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: const Icon(Icons.check, color: Colors.white),
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
