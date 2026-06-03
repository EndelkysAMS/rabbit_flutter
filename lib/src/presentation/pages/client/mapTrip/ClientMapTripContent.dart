import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultImageUrl.dart';

class ClientMapTripContent extends StatelessWidget {
  ClientMapTripState state;
  ClientRequestResponse? clientRequest;

  ClientMapTripContent(this.state, this.clientRequest);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _googleMaps(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: _cardBookingInfo(context),
        ),
      ],
    );
  }

  Widget _cardBookingInfo(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.46,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            'Tu Conductor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF8000),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${clientRequest?.driver?.name} ${clientRequest?.driver?.lastname}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Tel: ${clientRequest?.driver?.phone}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clientRequest?.bike?.brand ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${clientRequest?.bike?.color} - ${clientRequest?.bike?.plate}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Llega en ${state.timeAndDistanceValues?.duration.text} Aproximadamente',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF8000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  DefaultImageUrl(url: clientRequest?.driver?.image, width: 55),
                  const SizedBox(height: 8),
                  Image.asset('assets/img/motorbike.png', height: 35, width: 35),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
          const SizedBox(height: 8),
          const Text(
            'Datos del Viaje',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF8000),
            ),
          ),
          const SizedBox(height: 6),
          _infoRow(
            icon: Icons.location_on,
            title: 'Ubicaciones',
            subtitle: 'Desde: ${clientRequest?.pickupDescription}\nHasta: ${clientRequest?.destinationDescription}',
          ),
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
          _infoRow(
            icon: Icons.monetization_on_outlined,
            title: 'Valor del viaje',
            subtitle: '${clientRequest?.fareAssigned}',
            subtitleColor: const Color(0xFFFF8000),
            subtitleBold: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Color subtitleColor = Colors.black87,
    bool subtitleBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF8000), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: subtitleBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _googleMaps(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.555,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: state.cameraPosition,
        markers: Set<Marker>.of(state.markers.values),
        polylines: Set<Polyline>.of(state.polylines.values),
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle('[]');
          if (state.controller != null) {
            if (!state.controller!.isCompleted) {
              state.controller?.complete(controller);
              if (clientRequest != null) {
                context.read<ClientMapTripBloc>().add(AddMarkerPickup(
                    lat: clientRequest!.pickupPosition.y,
                    lng: clientRequest!.pickupPosition.x));
              }
            }
          }
        },
      ),
    );
  }
}