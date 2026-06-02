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
      height: MediaQuery.of(context).size.height * 0.49,
      padding: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Recoger en',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFF8000),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              state.pickUpDescription,
              style: const TextStyle(fontSize: 13),
            ),
            leading: const Icon(
              Icons.location_on,
              color: Color(0xFFFF8000),
            ),
          ),
          ListTile(
            title: const Text(
              'Dejar en',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFF8000),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              state.destinationDescription,
              style: const TextStyle(fontSize: 13),
            ),
            leading: const Icon(
              Icons.my_location,
              color: Color(0xFFFF8000),
            ),
          ),
          ListTile(
            title: const Text(
              'Tiempo y distancia aproximados',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFF8000),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${timeAndDistanceValues.distance.text} y ${timeAndDistanceValues.duration.text}',
              style: const TextStyle(fontSize: 13),
            ),
            leading: const Icon(
              Icons.timer,
              color: Color(0xFFFF8000),
            ),
          ),
          ListTile(
            title: const Text(
              'Precios Recomendados',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFF8000),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Bs. ${timeAndDistanceValues.recommendedValue}',
              style: const TextStyle(fontSize: 13),
            ),
            leading: const Icon(
              Icons.money,
              color: Color(0xFFFF8000),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: DefaultTextField(
              hintText: 'Ofrece tu Tarifa',
              icon: Icons.attach_money,
              keyboardType: TextInputType.phone,
              onChanged: (text) {
                context.read<ClientMapBookingInfoBloc>().add(
                  FareOfferedChanged(fareOffered: BlocFormItem(value: text)),
                );
              },
              validator: (value) {
                return state.fareOffered.error;
              },
            ),
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
              color: Color(0xFFFF8000),
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
      height: MediaQuery.of(context).size.height * 0.53,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: state.cameraPosition,
        markers: Set<Marker>.of(state.markers.values),
        polylines: Set<Polyline>.of(state.polylines.values),
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle('[ { "featureType": "all", "elementType": "labels.text.fill", "stylers": [ { "color": "#ffffff" } ] }, { "featureType": "all", "elementType": "labels.text.stroke", "stylers": [ { "color": "#000000" }, { "lightness": 13 } ] }, { "featureType": "administrative", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "administrative", "elementType": "geometry.stroke", "stylers": [ { "color": "#144b53" }, { "lightness": 14 }, { "weight": 1.4 } ] }, { "featureType": "landscape", "elementType": "all", "stylers": [ { "color": "#08304b" } ] }, { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#0c4152" }, { "lightness": 5 } ] }, { "featureType": "road.highway", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#0b434f" }, { "lightness": 25 } ] }, { "featureType": "road.arterial", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "road.arterial", "elementType": "geometry.stroke", "stylers": [ { "color": "#0b3d51" }, { "lightness": 16 } ] }, { "featureType": "road.local", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "transit", "elementType": "all", "stylers": [ { "color": "#146474" } ] }, { "featureType": "water", "elementType": "all", "stylers": [ { "color": "#021019" } ] } ]');
          if (!state.controller!.isCompleted) {
            state.controller?.complete(controller);
          }
        },
      ),
    );
  }
}