import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/ratingTrip/bloc/DriverRatingTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/ratingTrip/bloc/DriverRatingTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/ratingTrip/bloc/DriverRatingTripState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultButton.dart';

class DriverRatingTripContent extends StatelessWidget {
  final DriverRatingTripState driverRatingTripState;
  final ClientRequestResponse? clientRequestResponse;

  DriverRatingTripContent(
      this.driverRatingTripState, this.clientRequestResponse);

  @override
  Widget build(BuildContext context) {
    final minHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              children: [
            _iconCheck(),
            const SizedBox(height: 15),
            _textFinished(),
            const SizedBox(height: 24),
            _listTilePickup(),
            _listTileDestination(),
            const SizedBox(height: 32),
            _textFare(),
            _textFareValue(),
            const SizedBox(height: 20),
            _textRateYourClient(),
            _ratingBar(context),
            const SizedBox(height: 32),
            DefaultButton(
              text: 'Calificar Cliente',
              width: 240,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onPressed: () {
                context.read<DriverRatingTripBloc>().add(
                    UpdateRating(idClientRequest: clientRequestResponse!.id));
              },
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFareValue() {
    return Text(
      '${clientRequestResponse?.fareAssigned}',
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 35, color: Colors.yellow),
    );
  }

  Widget _textFare() {
    return Text(
      'Valor del Viaje',
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
    );
  }

  Widget _textRateYourClient() {
    return Text(
      'Califica a tu Cliente',
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
    );
  }

  Widget _ratingBar(BuildContext context) {
    return RatingBar.builder(
        itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
        initialRating: 0,
        itemCount: 5,
        direction: Axis.horizontal,
        allowHalfRating: true,
        unratedColor: Colors.grey[300],
        onRatingUpdate: (rating) {
          context
              .read<DriverRatingTripBloc>()
              .add(RatingChanged(rating: rating));
        });
  }

  Widget _listTileDestination() {
    return ListTile(
      leading: Icon(
        Icons.flag,
        color: Colors.white,
      ),
      title: Text(
        'Hasta',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        clientRequestResponse?.destinationDescription ?? '',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _listTilePickup() {
    return ListTile(
      leading: Icon(
        Icons.location_on,
        color: Colors.white,
      ),
      title: Text(
        'desde',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        clientRequestResponse?.pickupDescription ?? '',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _textFinished() {
    return Text(
      'Tu viaje ha finalizado',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _iconCheck() {
    return Icon(
      Icons.check_circle,
      color: Colors.white,
      size: 72,
    );
  }
}
