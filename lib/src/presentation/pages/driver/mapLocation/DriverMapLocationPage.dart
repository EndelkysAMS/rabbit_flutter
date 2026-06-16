import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:rabbit_flutter/src/debug/agent_debug_log.dart';
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

class _DriverMapLocationPageState extends State<DriverMapLocationPage>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  bool _initialCameraSynced = false;
  String? _lastLocationErrorShown;

  Future<void> _openLocationSettings(String error) async {
    if (error.contains('Ajustes de la app')) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }

  void _syncMapWithState(DriverMapLocationState state) {
    final completer = state.controller;
    if (_mapController != null &&
        completer != null &&
        !completer.isCompleted) {
      completer.complete(_mapController!);
      context.read<DriverMapLocationBloc>().add(RetryPendingCamera());
      // #region agent log
      agentDebugLog(
        location: 'DriverMapLocationPage.dart:_syncMapWithState',
        message: 'Map controller completed',
        data: {
          'hasPosition': state.position != null,
          'markerCount': state.markers.length,
        },
        hypothesisId: 'A',
      );
      // #endregion
    }

    if (!_initialCameraSynced &&
        _mapController != null &&
        completer?.isCompleted == true &&
        state.position != null) {
      _initialCameraSynced = true;
      context.read<DriverMapLocationBloc>().add(ChangeMapCameraPosition(
            lat: state.position!.latitude,
            lng: state.position!.longitude,
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<BlocSocketIO>().add(ConnectSocketIO());
      context.read<DriverClientRequestsBloc>().add(InitDriverClientRequest());
      context
          .read<DriverClientRequestsBloc>()
          .add(ListenNewClientRequestSocketIO());
      context.read<DriverClientRequestsBloc>().add(EnableRealtimeRequests());
      context.read<DriverMapLocationBloc>().add(DriverMapLocationInitEvent());
      context.read<DriverMapLocationBloc>().add(FindPosition());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final mapState = context.read<DriverMapLocationBloc>().state;
      if (mapState.position == null || mapState.locationError != null) {
        context.read<DriverMapLocationBloc>().add(FindPosition());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DriverMapLocationBloc, DriverMapLocationState>(
            listenWhen: (previous, current) =>
                previous.locationError != current.locationError ||
                previous.position != current.position,
            listener: (context, state) {
              _syncMapWithState(state);
              final error = state.locationError;
              if (error != null && error != _lastLocationErrorShown) {
                _lastLocationErrorShown = error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    duration: const Duration(seconds: 6),
                    action: SnackBarAction(
                      label: 'Activar',
                      onPressed: () => _openLocationSettings(error),
                    ),
                  ),
                );
              }
              if (state.position != null && state.locationError == null) {
                _lastLocationErrorShown = null;
              }
            },
            builder: (context, state) {
              final mapMarkers = <Marker>{
                ...state.markers.values,
              };
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: state.cameraPosition,
                    markers: mapMarkers,
                    onMapCreated: (GoogleMapController controller) {
                      controller.setMapStyle('[]');
                      _mapController = controller;
                      final current =
                          context.read<DriverMapLocationBloc>().state;
                      // #region agent log
                      agentDebugLog(
                        location: 'DriverMapLocationPage.dart:onMapCreated',
                        message: 'onMapCreated',
                        data: {
                          'controllerCompleted':
                              current.controller?.isCompleted ?? false,
                          'hasPosition': current.position != null,
                          'markerCount': current.markers.length,
                        },
                        hypothesisId: 'A',
                      );
                      // #endregion
                      _syncMapWithState(current);
                    },
                  ),
                  if (state.locationError != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.location_off, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.locationError!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _openLocationSettings(state.locationError!),
                                child: const Text('Activar GPS'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
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
