import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/ratingTrip/bloc/ClientRatingTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/ratingTrip/bloc/ClientRatingTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/ratingTrip/bloc/ClientRatingTripState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultButton.dart';

class ClientRatingTripContent extends StatelessWidget {
  
  final ClientRatingTripState state;
  final ClientRequestResponse? clientRequestResponse;

  const ClientRatingTripContent(this.state, this.clientRequestResponse, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        _iconCheck(),
        const SizedBox(height: 15),
        _textFinished(),
        const SizedBox(height: 30),
        _listTilePickup(),
        _listTileDestination(),
        const SizedBox(height: 70),
        _textFare(),
        _textFareValue(),
        const SizedBox(height: 20),
        _textRateYourClient(),
        _ratingBar(context),
        const Spacer(),
        DefaultButton(
          text: 'Calificar Conductor',
          onPressed: () {
            context.read<ClientRatingTripBloc>().add(
              UpdateRating(idClientRequest: clientRequestResponse!.id),
            );
          },
        ),
      ],
    );
  }

  Widget _textFareValue() {
    return Text(
      'Bs. ${clientRequestResponse?.fareAssigned}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 35,
        color: Colors.yellow,
      ),
    );
  }

  Widget _textFare() {
    return const Text(
      'Valor del Viaje',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _textRateYourClient() {
    return const Text(
      'Califica a tu Conductor',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _ratingBar(BuildContext context) {
    return RatingBar.builder(
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      initialRating: 0,
      itemCount: 5,
      direction: Axis.horizontal,
      allowHalfRating: true,
      unratedColor: Colors.grey[300],
      onRatingUpdate: (rating) {
        context.read<ClientRatingTripBloc>().add(RatingChanged(rating: rating));
      },
    );
  }

  Widget _listTileDestination() {
    return ListTile(
      leading: const Icon(Icons.flag, color: Colors.white),
      title: const Text(
        'Hasta',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        clientRequestResponse?.destinationDescription ?? '',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _listTilePickup() {
    return ListTile(
      leading: const Icon(Icons.location_on, color: Colors.white),
      title: const Text(
        'Desde',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        clientRequestResponse?.pickupDescription ?? '',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _textFinished() {
    return const Text(
      'Tu viaje ha finalizado',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _iconCheck() {
    return const Icon(
      Icons.check_circle,
      color: Colors.white,
      size: 100,
    );
  }
}