import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/ratingTrip/DriverRatingTripContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/ratingTrip/bloc/DriverRatingTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/ratingTrip/bloc/DriverRatingTripState.dart';

class DriverRatingTripPage extends StatefulWidget {
  const DriverRatingTripPage({super.key});

  @override
  State<DriverRatingTripPage> createState() => _DriverRatingTripPageState();
}

class _DriverRatingTripPageState extends State<DriverRatingTripPage> {
  ClientRequestResponse? clientRequestResponse;
  @override
  Widget build(BuildContext context) {
    clientRequestResponse =
        ModalRoute.of(context)?.settings.arguments as ClientRequestResponse;
    return Scaffold(
      body: BlocListener<DriverRatingTripBloc, DriverRatingTripState>(
        listener: (context, state) {
          final response = state.response;
          if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
          }
          else if (response is Success) {
            Navigator.pushNamedAndRemoveUntil(context, 'driver/home', (route) => false);
          }
        },
        child: BlocBuilder<DriverRatingTripBloc, DriverRatingTripState>(
          builder: (context, state) {
            return Container(
               decoration: const BoxDecoration(
              color: Color(0xFFFF8000),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
                child: DriverRatingTripContent(state, clientRequestResponse));
          },
        ),
      ),
    );
  }
}