import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/DriverBikeInfoContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikeInfoBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikeInfoState.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikoInfoEvent.dart';

class DriverBikeInfoPage extends StatefulWidget {
  const DriverBikeInfoPage({super.key});

  @override
  State<DriverBikeInfoPage> createState() => _DriverBikeInfoPageState();
}

class _DriverBikeInfoPageState extends State<DriverBikeInfoPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<DriverBikeInfoBloc>().add(DriverBikeInfoInitEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DriverBikeInfoBloc, DriverBikeInfoState>(
        listener: (context, state) {
          final response = state.response;
          if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
          }
          else if (response is Success) {
            Fluttertoast.showToast(msg: 'Actualizacion exitosa', toastLength: Toast.LENGTH_LONG);
          }
        },
        child: BlocBuilder<DriverBikeInfoBloc, DriverBikeInfoState>(
          builder: (context, state) {
            final response = state.response;
            if (response is Loading) {
              return Stack(
                children: [
                  DriverBikeInfoContent(state),
                  Center(child: CircularProgressIndicator())
                ],
              );
            }
            return DriverBikeInfoContent(state);
          },
        ),
      ),
    );
  }
}