import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultButton.dart';

class ClientDriverOffersItem extends StatelessWidget {

  final DriverTripRequest? driverTripRequest;

  const ClientDriverOffersItem(this.driverTripRequest, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              leading: _imageUser(),
              title: Text(
                '${driverTripRequest?.driver?.name ?? ''} ${driverTripRequest?.driver?.lastname ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '5.0',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    driverTripRequest?.bike?.brand ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${driverTripRequest?.time} min',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${driverTripRequest?.distance} km',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, bottom: 15, top: 10),
                child: Text(
                  'Bs. ${driverTripRequest?.fareOffered}',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8000),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 15, top: 10),
                child: DefaultButton(
                  text: 'Aceptar',
                  onPressed: () {
                    context.read<ClientDriverOffersBloc>().add(
                      AssignDriver(
                        idClientRequest: driverTripRequest!.idClientRequest,
                        idDriver: driverTripRequest!.idDriver,
                        fareAssigned: driverTripRequest!.fareOffered,
                        context: context,
                      ),
                    );
                  },
                  width: 120,
                  height: 40,
                  backgroundColor: const Color(0xFFFF8000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageUser() {
    return Container(
      width: 60,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: driverTripRequest != null
              ? driverTripRequest!.driver!.image != null
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/img/user_image.jpg',
                      image: driverTripRequest!.driver!.image!,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(seconds: 1),
                    )
                  : Image.asset('assets/img/user_image.jpg')
              : Container(),
        ),
      ),
    );
  }
}