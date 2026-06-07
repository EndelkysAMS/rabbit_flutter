import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/src/domain/models/TimeAndDistanceValues.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBookingInfoBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBookingInfoState.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBoolingInfoEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultIconBack.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultTextField.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class ClientMapBookingInfoContent extends StatelessWidget {
  final ClientMapBookingInfoState state;
  final TimeAndDistanceValues timeAndDistanceValues;

  const ClientMapBookingInfoContent(this.state, this.timeAndDistanceValues);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _googleMaps(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: _cardBookingInfo(context),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50, left: 20),
          child: DefaultIconBack(),
        ),
      ],
    );
  }

  Widget _cardBookingInfo(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          _infoRow(
            icon: Icons.location_on,
            title: 'Recoger en',
            subtitle: state.pickUpDescription,
          ),
          _divider(),
          _infoRow(
            icon: Icons.my_location,
            title: 'Dejar en',
            subtitle: state.destinationDescription,
          ),
          _divider(),
          _infoRow(
            icon: Icons.timer,
            title: 'Tiempo y distancia aproximados',
            subtitle: '${timeAndDistanceValues.distance.text} y ${timeAndDistanceValues.duration.text}',
          ),
          _divider(),
          _infoRow(
            icon: Icons.monetization_on_outlined,
            title: 'Precios Recomendados',
            subtitle: ' ${timeAndDistanceValues.recommendedValue}',
          ),
          const SizedBox(height: 12),
          DefaultTextField(
            hintText: 'Ofrece tu Tarifa',
            icon: Icons.attach_money,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (text) {
              context.read<ClientMapBookingInfoBloc>().add(
                FareOfferedChanged(fareOffered: BlocFormItem(value: text)),
              );
            },
            validator: (value) {
              return state.fareOffered.error;
            },
          ),
          _actionProfile(
            'Buscar Conductor',
            Icons.search,
            () {
              context.read<ClientMapBookingInfoBloc>().add(CreateClientRequest());
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 0, 0, 0), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[200],
    );
  }

  Widget _actionProfile(String option, IconData icon, Function() function) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 0, top: 15),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            option,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 250, 138, 25),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleMaps(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: state.cameraPosition,
        markers: Set<Marker>.of(state.markers.values),
        polylines: Set<Polyline>.of(state.polylines.values),
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle('[]');
          if (!state.controller!.isCompleted) {
            state.controller?.complete(controller);
          }
          if (state.polylines.isNotEmpty) {
            context.read<ClientMapBookingInfoBloc>().add(FitRouteCamera());
          }
        },
      ),
    );
  }
}