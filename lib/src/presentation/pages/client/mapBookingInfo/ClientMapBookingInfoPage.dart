import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/src/domain/models/TimeAndDistanceValues.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/ClientMapBookingInfoContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBookingInfoBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBookingInfoState.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBoolingInfoEvent.dart';

class ClientMapBookingInfoPage extends StatefulWidget {
  const ClientMapBookingInfoPage({super.key});

  @override
  State<ClientMapBookingInfoPage> createState() =>
      _ClientMapBookingInfoPageState();
}

class _ClientMapBookingInfoPageState extends State<ClientMapBookingInfoPage> {
  LatLng? pickUpLatLng;
  LatLng? destinationLatLng;
  String? pickUpDestination;
  String? destinationDescription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .read<ClientMapBookingInfoBloc>()
          .add(ClientMapBookingInfoInitEvent(
            pickUpLatLng: pickUpLatLng!,
            destinationLatLng: destinationLatLng!,
            pickUpDescription: pickUpDestination!,
            destinationDescription: destinationDescription!,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    pickUpLatLng = arguments['pickUpLatLng'];
    destinationLatLng = arguments['destinationLatLng'];
    pickUpDestination = arguments['pickUpDescription'];
    destinationDescription = arguments['destinationDescription'];
    return Scaffold(
      body: BlocListener<ClientMapBookingInfoBloc, ClientMapBookingInfoState>(
        listener: (context, state) {
          final responseClientRequest = state.responseClientRequest;
          if (responseClientRequest is Success) {
            int idClientRequest = responseClientRequest.data;
            context.read<ClientMapBookingInfoBloc>().add(
                EmitNewClientRequestSocketIO(idClientRequest: idClientRequest));
            // Navigator.pushNamedAndRemoveUntil(context, 'client/driver/offers', (route) => false);
            Navigator.pushNamed(context, 'client/driver/offers', arguments: {
              'idClientRequest': idClientRequest,
            });
            Fluttertoast.showToast(
                msg: 'Solicitud enviada', toastLength: Toast.LENGTH_LONG);
          } else if (responseClientRequest is ErrorData) {
            Fluttertoast.showToast(
              msg: responseClientRequest.message,
              toastLength: Toast.LENGTH_LONG,
            );
          }
        },
        child: BlocBuilder<ClientMapBookingInfoBloc, ClientMapBookingInfoState>(
          builder: (context, state) {
            final responseTimeAndDistance = state.responseTimeAndDistance;
            if (responseTimeAndDistance is Loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (responseTimeAndDistance is Success) {
              TimeAndDistanceValues timeAndDistanceValues =
                  responseTimeAndDistance.data as TimeAndDistanceValues;
              return ClientMapBookingInfoContent(state, timeAndDistanceValues);
            } else if (responseTimeAndDistance is ErrorData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        responseTimeAndDistance.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
