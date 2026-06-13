import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/bloc/DriverMapLocationEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/bloc/DriverMapLocationBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapLocation/bloc/DriverMapLocationState.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DriverMapLocationPage extends StatefulWidget {
  const DriverMapLocationPage({super.key});

  @override
  State<DriverMapLocationPage> createState() => _DriverMapLocationPageState();
}

class _DriverMapLocationPageState extends State<DriverMapLocationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<DriverClientRequestsBloc>().add(InitDriverClientRequest());
      context
          .read<DriverClientRequestsBloc>()
          .add(ListenNewClientRequestSocketIO());
      context.read<DriverMapLocationBloc>().add(DriverMapLocationInitEvent());
      context.read<DriverMapLocationBloc>().add(FindPosition());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DriverMapLocationBloc, DriverMapLocationState>(
            builder: (context, state) {
              final mapMarkers = <Marker>{
                ...state.markers.values,
              };
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: state.cameraPosition,
                    markers: mapMarkers,
                    onMapCreated: (GoogleMapController controller) {
                      controller.setMapStyle('[]');
                      if (!state.controller!.isCompleted) {
                        state.controller?.complete(controller);
                      }
                    },
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 30),
                    child: ToggleSwitch(
                      minWidth: 130.0,
                      minHeight: 50,
                      cornerRadius: 20.0,
                      activeBgColors: [
                        [Colors.yellow],
                        [Colors.red]
                      ],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey[400],
                      inactiveFgColor: Colors.white,
                      initialLabelIndex: 0,
                      totalSwitches: 2,
                      customTextStyles: [
                        TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic)
                      ],
                      labels: ['Conectado', 'Desconectado'],
                      radiusStyle: true,
                      onToggle: (index) {
                        if (index == 0) {
                          //CONECTADO
                          context.read<BlocSocketIO>().add(ConnectSocketIO());
                          context
                              .read<DriverMapLocationBloc>()
                              .add(FindPosition());
                          context
                              .read<DriverClientRequestsBloc>()
                              .add(EnableRealtimeRequests());
                          context
                              .read<DriverClientRequestsBloc>()
                              .add(GetNearbyTripRequest());
                        } else if (index == 1) {
                          // DESCONECTADO
                          context
                              .read<BlocSocketIO>()
                              .add(DisconnectSocketIO());
                          context
                              .read<DriverClientRequestsBloc>()
                              .add(DisableRealtimeRequests());
                          context
                              .read<DriverMapLocationBloc>()
                              .add(StopLocation());
                        }
                        print('switched to: $index');
                      },
                    ),
                  ),
                  const SizedBox.shrink(),
                ],
              );
            },
      ),
    );
  }
}
