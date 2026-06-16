import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/models/StatusTrip.dart';
import 'package:rabbit_flutter/src/domain/models/TimeAndDistanceValues.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultImageUrl.dart';

class DriverMapTripContent extends StatelessWidget {
  final DriverMapTripState state;
  final ClientRequestResponse? clientRequest;
  final TimeAndDistanceValues? timeAndDistanceValues;

  const DriverMapTripContent(
      this.state, this.clientRequest, this.timeAndDistanceValues,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final maxPanelHeight = MediaQuery.of(context).size.height * 0.46;

    return Stack(
      children: [
        Positioned.fill(child: _googleMaps(context)),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: _cardBookingInfo(context, maxPanelHeight),
          ),
        ),
      ],
    );
  }

  Widget _cardBookingInfo(BuildContext context, double maxPanelHeight) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxPanelHeight),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              'Tu Cliente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8000),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${clientRequest?.client.name ?? ''} ${clientRequest?.client.lastname ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Tel: ${clientRequest?.client.phone ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _etaText(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF8000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultImageUrl(
                  url: clientRequest?.client.image,
                  width: 52,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Datos del Viaje',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8000),
              ),
            ),
            const SizedBox(height: 4),
            _infoRow(
              icon: Icons.location_on,
              title: 'Ubicaciones',
              subtitle:
                  'Desde: ${clientRequest?.pickupDescription ?? ''}\nHasta: ${clientRequest?.destinationDescription ?? ''}',
            ),
            _infoRow(
              icon: Icons.monetization_on_outlined,
              title: 'Valor del viaje',
              subtitle: '${clientRequest?.fareAssigned ?? ''}',
              subtitleColor: const Color(0xFFFF8000),
              subtitleBold: true,
            ),
            const SizedBox(height: 8),
            state.statusTrip == StatusTrip.ARRIVED
                ? _actionUpdateStatus(
                    'FINALIZAR VIAJE', Icons.power_settings_new, () {
                    context
                        .read<DriverMapTripBloc>()
                        .add(UpdateStatusToFinished());
                  })
                : _actionUpdateStatus('NOTIFICAR LLEGADA', Icons.check, () {
                    context
                        .read<DriverMapTripBloc>()
                        .add(UpdateStatusToArrived());
                  }),
          ],
        ),
      ),
    );
  }

  String _etaText() {
    final durationText = timeAndDistanceValues?.duration.text ??
        clientRequest?.googleDistanceMatrix?.duration.text;
    final distanceText = timeAndDistanceValues?.distance.text ??
        clientRequest?.googleDistanceMatrix?.distance.text;
    if (durationText == null || durationText.isEmpty) {
      return 'Tiempo estimado: --';
    }
    if (distanceText == null || distanceText.isEmpty) {
      return 'Tiempo estimado: $durationText';
    }
    return 'Tiempo estimado: $durationText ($distanceText)';
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight:
                        subtitleBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionUpdateStatus(
      String option, IconData icon, VoidCallback function) {
    return InkWell(
      onTap: function,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFFF8000),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleMaps(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: state.cameraPosition,
      markers: Set<Marker>.of(state.markers.values),
      polylines: Set<Polyline>.of(state.polylines.values),
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle('[]');
        if (state.controller != null && !state.controller!.isCompleted) {
          state.controller?.complete(controller);
        }
      },
    );
  }
}
