import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/ratingTrip/ClientRatingTripContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/ratingTrip/bloc/ClientRatingTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/ratingTrip/bloc/ClientRatingTripState.dart';

class ClientRatingTripPage extends StatefulWidget {
  const ClientRatingTripPage({super.key});

  @override
  State<ClientRatingTripPage> createState() => _ClientRatingTripPageState();
}

class _ClientRatingTripPageState extends State<ClientRatingTripPage> {
  ClientRequestResponse? clientRequestResponse;

  @override
  Widget build(BuildContext context) {
    clientRequestResponse = ModalRoute.of(context)?.settings.arguments as ClientRequestResponse;
    return Scaffold(
      backgroundColor: const Color(0xFFFF8000),
      body: BlocListener<ClientRatingTripBloc, ClientRatingTripState>(
        listener: (context, state) {
          final response = state.response;
          if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
          }
          else if (response is Success) {
            Navigator.pushNamedAndRemoveUntil(context, 'client/home', (route) => false);
          }
        },
        child: BlocBuilder<ClientRatingTripBloc, ClientRatingTripState>(
          builder: (context, state) {
            return SizedBox.expand(
              child: ColoredBox(
                color: const Color(0xFFFF8000),
                child: ClientRatingTripContent(state, clientRequestResponse),
              ),
            );
          },
        ),
      ),
    );
  }
}