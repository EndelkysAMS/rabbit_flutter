import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/DriverClientRequestsItem.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsState.dart';

class DriverClientRequestsPage extends StatefulWidget {
  const DriverClientRequestsPage({super.key});

  @override
  State<DriverClientRequestsPage> createState() =>
      _DriverClientRequestsPageState();
}

class _DriverClientRequestsPageState extends State<DriverClientRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final bloc = context.read<DriverClientRequestsBloc>();
      bloc.add(InitDriverClientRequest());
      bloc.add(ListenNewClientRequestSocketIO());

      // Si se abrió desde la notificación push con un id concreto,
      // centramos esa solicitud.
      final args = ModalRoute.of(context)?.settings.arguments;
      final idClientRequest =
          args is int ? args : int.tryParse(args?.toString() ?? '');
      if (idClientRequest != null && idClientRequest > 0) {
        bloc.add(SetActiveRequestById(idClientRequest: idClientRequest));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<DriverClientRequestsBloc, DriverClientRequestsState>(
        listener: (context, state) {
          final responseCreateTripRequest =
              state.responseCreateDriverTripRequest;
          if (responseCreateTripRequest is Success) {
            Fluttertoast.showToast(
                msg: 'La oferta se ha enviado correctamente',
                toastLength: Toast.LENGTH_LONG);
          } else if (responseCreateTripRequest is ErrorData) {
            Fluttertoast.showToast(
                msg: responseCreateTripRequest.message,
                toastLength: Toast.LENGTH_LONG);
          }
          final response = state.response;
          if (response is ErrorData &&
              response.message.toLowerCase().contains('401')) {
            Fluttertoast.showToast(
                msg: response.message, toastLength: Toast.LENGTH_LONG);
          }
        },
        child: BlocBuilder<DriverClientRequestsBloc, DriverClientRequestsState>(
            builder: (context, state) {
          if (state.nearbyRequests.isNotEmpty) {
            return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return DriverClientRequestsItem(
                      state, state.nearbyRequests.first);
                });
          }
          final response = state.response;
          if (response is Loading && state.nearbyRequests.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else if (response is Success) {
            List<ClientRequestResponse> clientRequests =
                response.data as List<ClientRequestResponse>;
            if (clientRequests.isEmpty) {
              return const Center(
                child: Text('Sin solicitudes cercanas por el momento'),
              );
            }
            return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return DriverClientRequestsItem(state, clientRequests.first);
                });
          }
          return const Center(
            child: Text('Sin solicitudes cercanas por el momento'),
          );
        }),
      ),
      ),
    );
  }
}
