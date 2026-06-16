import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapSeeker/bloc/ClientMapSeekerBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapSeeker/bloc/ClientMapSeekerEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapSeeker/bloc/ClientMapSeekerState.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/DefaultButton.dart';
import 'package:rabbit_flutter/src/presentation/pages/widgets/GooglePlacesAutoComplete.dart';

class ClientMapSeekerPage extends StatefulWidget {
  const ClientMapSeekerPage({super.key});

  @override
  State<ClientMapSeekerPage> createState() => _ClientMapSeekerPageState();
}

class _ClientMapSeekerPageState extends State<ClientMapSeekerPage> {
  TextEditingController pickUpController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<BlocSocketIO>().add(ConnectSocketIO());
      context.read<ClientMapSeekerBloc>().add(ClientMapSeekerInitEvent());
      context.read<ClientMapSeekerBloc>().add(ListenDriversPositionSocketIO());
      context.read<ClientMapSeekerBloc>().add(ListenDriversDisconnectedSocketIO());
      context.read<ClientMapSeekerBloc>().add(FindPosition());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ClientMapSeekerBloc, ClientMapSeekerState>(
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: state.cameraPosition,
                  markers: Set<Marker>.of(state.markers.values),
                  onCameraMove: (CameraPosition cameraPosition) {
                    context.read<ClientMapSeekerBloc>().add(
                        OnCameraMove(cameraPosition: cameraPosition));
                  },
                  onCameraIdle: () async {
                    context.read<ClientMapSeekerBloc>().add(OnCameraIdle());
                    pickUpController.text = state.placemarkData?.address ?? '';
                    if (state.placemarkData != null) {
                      context.read<ClientMapSeekerBloc>().add(
                          OnAutoCompletedPickUpSelected(
                            lat: state.placemarkData!.lat,
                            lng: state.placemarkData!.lng,
                            pickUpDescription: state.placemarkData!.address,
                          ));
                    }
                  },
                  onMapCreated: (GoogleMapController controller) {
                    controller.setMapStyle('[]');
                    if (state.controller != null) {
                      if (!state.controller!.isCompleted) {
                        state.controller?.complete(controller);
                      }
                    }
                  },
                ),
              ),
              _iconMyLocation(),
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _googlePlacesAutocomplete(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(64, 0, 64, 16),
                    child: DefaultButton(
                      text: 'Revisar Viaje',
                      width: double.infinity,
                      onPressed: () {
                        if (state.pickUpLatLng == null ||
                            state.destinationLatLng == null) {
                          Fluttertoast.showToast(
                            msg: 'Selecciona el origen y el destino',
                            toastLength: Toast.LENGTH_LONG,
                          );
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          'client/map/booking',
                          arguments: {
                            'pickUpLatLng': state.pickUpLatLng,
                            'destinationLatLng': state.destinationLatLng,
                            'pickUpDescription': state.pickUpDescription,
                            'destinationDescription':
                                state.destinationDescription,
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _googlePlacesAutocomplete() {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GooglePlacesAutoComplete(
                pickUpController,
                'Recoger en',
                (Prediction prediction) {
                  context.read<ClientMapSeekerBloc>().add(ChangeMapCameraPosition(
                        lat: double.parse(prediction.lat!),
                        lng: double.parse(prediction.lng!),
                      ));
                  context.read<ClientMapSeekerBloc>().add(
                      OnAutoCompletedPickUpSelected(
                        lat: double.parse(prediction.lat!),
                        lng: double.parse(prediction.lng!),
                        pickUpDescription: prediction.description ?? '',
                      ));
                },
              ),
              Divider(height: 1, color: Colors.grey[200]),
              GooglePlacesAutoComplete(
                destinationController,
                'Dejar en',
                (Prediction prediction) {
                  context.read<ClientMapSeekerBloc>().add(
                      OnAutoCompletedDestinationSelected(
                        lat: double.parse(prediction.lat!),
                        lng: double.parse(prediction.lng!),
                        destinationDescription: prediction.description ?? '',
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconMyLocation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Image.asset(
          'assets/img/location_orange.png',
          width: 44,
          height: 44,
        ),
      ),
    );
  }
}