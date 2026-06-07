import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextField.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class DriverClientRequestsItem extends StatelessWidget {
  final DriverClientRequestsState state;
  final ClientRequestResponse? clientRequest;

  DriverClientRequestsItem(this.state, this.clientRequest);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FareOfferedDialog(context, () {
          if (clientRequest != null &&
              state.idDriver != null &&
              context
                  .read<DriverClientRequestsBloc>()
                  .state
                  .fareOffered
                  .value
                  .isNotEmpty) {
            context
                .read<DriverClientRequestsBloc>()
                .add(CreateDriverTripRequest(
                    driverTripRequest: DriverTripRequest(
                  idDriver: state.idDriver!,
                  idClientRequest: clientRequest!.id,
                  fareOffered: double.parse(context
                      .read<DriverClientRequestsBloc>()
                      .state
                      .fareOffered
                      .value),
                  time: _safeTripMinutes(),
                  distance: _safeTripDistanceKm(),
                )));
          } else {
            Fluttertoast.showToast(
                msg: 'No se puede enviar la oferta',
                toastLength: Toast.LENGTH_LONG);
          }
        });
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFF8000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ListTile(
                trailing: _imageUser(),
                title: Text(
                  'Tarifa ofrecida: \$ ${clientRequest?.fareOffered}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${clientRequest?.client.name} ${clientRequest?.client.lastname}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Datos del viaje',
                style: TextStyle(
                  color: Color(0xFFFF8000),
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                children: [
                  _textPickup(),
                  _textDestination(),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                'Tiempo y Distancia',
                style: TextStyle(
                  color: Color(0xFFFF8000),
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                children: [
                  _textMinutesRow(),
                  _textDistanceRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textMinutesRow() {
    return Row(
      children: [
        Container(
          width: 140,
          child: const Text(
            'Tiempo de llegada: ',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(child: Text(_minutesText())),
      ],
    );
  }

  Widget _textDistanceRow() {
    return Row(
      children: [
        Container(
          width: 140,
          child: const Text(
            'Recorrido: ',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(child: Text(_distanceText())),
      ],
    );
  }

  Widget _textPickup() {
    return Row(
      children: [
        Container(
          width: 90,
          child: const Text(
            'Recoger en: ',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: Text(clientRequest?.pickupDescription ?? ''),
        ),
      ],
    );
  }

  Widget _textDestination() {
    return Row(
      children: [
        Container(
          width: 90,
          child: const Text(
            'Llevar a: ',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: Text(clientRequest?.destinationDescription ?? ''),
        ),
      ],
    );
  }

  Widget _imageUser() {
    return Container(
      width: 60,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: clientRequest != null
              ? clientRequest!.client.image != null
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/img/user_image.jpg',
                      image: clientRequest?.client.image,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(seconds: 1),
                    )
                  : Image.asset('assets/img/user_image.jpg')
              : Container(),
        ),
      ),
    );
  }

  FareOfferedDialog(BuildContext context, Function() submit) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Ingresa tu tarifa',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF8000),
          ),
        ),
        contentPadding: const EdgeInsets.only(bottom: 15),
        content: DefaultTextField(
          hintText: 'Valor',
          icon: Icons.attach_money,
          keyboardType: TextInputType.phone,
          onChanged: (text) {
            context.read<DriverClientRequestsBloc>().add(
                  FareOfferedChange(fareOffered: BlocFormItem(value: text)),
                );
          },
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              submit();
            },
            child: const Text('Enviar tarifa'),
          ),
        ],
      ),
    );
  }

  double _safeTripMinutes() {
    final fromMatrix = clientRequest?.googleDistanceMatrix?.duration.value;
    if (fromMatrix != null) return fromMatrix / 60;
    return clientRequest?.timeDifference != null
        ? double.tryParse(clientRequest!.timeDifference!) ?? 0
        : 0;
  }

  double _safeTripDistanceKm() {
    final fromMatrix = clientRequest?.googleDistanceMatrix?.distance.value;
    if (fromMatrix != null) return fromMatrix / 1000;
    return clientRequest?.distance ?? 0;
  }

  String _minutesText() {
    final text = clientRequest?.googleDistanceMatrix?.duration.text;
    if (text != null && text.isNotEmpty) return text;
    final minutes = _safeTripMinutes();
    if (minutes <= 0) return '--';
    return '${minutes.toStringAsFixed(1)} min';
  }

  String _distanceText() {
    final text = clientRequest?.googleDistanceMatrix?.distance.text;
    if (text != null && text.isNotEmpty) return text;
    final km = _safeTripDistanceKm();
    if (km <= 0) return '--';
    return '${km.toStringAsFixed(1)} km';
  }
}
