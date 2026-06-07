import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/DriverMapTripContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/mapTrip/bloc/DriverMapTripState.dart';

class DriverMapTripPage extends StatefulWidget {
  const DriverMapTripPage({super.key});

  @override
  State<DriverMapTripPage> createState() => _DriverMapTripPageState();
}

class _DriverMapTripPageState extends State<DriverMapTripPage> {
  int? idClientRequest;
  bool _isInitialized = false;
  dynamic _lastArgs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_isInitialized && args == _lastArgs) return;
    _lastArgs = args;
    final bloc = context.read<DriverMapTripBloc>();
    bloc.add(InitDriverMapTripEvent());

    if (args is ClientRequestResponse) {
      // Viaje precargado desde el socket driver_assigned: sin segundo GET.
      idClientRequest = args.id;
      bloc.add(SetClientRequestData(clientRequest: args));
      _isInitialized = true;
      return;
    }

    final parsedId = args is int ? args : int.tryParse(args?.toString() ?? '');
    if (parsedId == null || parsedId <= 0) return;
    idClientRequest = parsedId;
    bloc.add(GetClientRequest(idClientRequest: idClientRequest!));
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    idClientRequest ??= (() {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) return args;
      return int.tryParse(args?.toString() ?? '');
    })();
    return Scaffold(
      body: BlocListener<DriverMapTripBloc, DriverMapTripState>(
        listener: (context, state) {
          final responseClientRequest = state.responseGetClientRequest;
          if (responseClientRequest is ErrorData) {
            Fluttertoast.showToast(
                msg: responseClientRequest.message,
                toastLength: Toast.LENGTH_LONG);
          }
        },
        child: BlocBuilder<DriverMapTripBloc, DriverMapTripState>(
          builder: (context, state) {
            final responseClientRequest = state.responseGetClientRequest;
            if (responseClientRequest is Success) {
              final data = responseClientRequest.data as ClientRequestResponse;
              return DriverMapTripContent(state, data, null);
            }
            if (responseClientRequest is ErrorData) {
              return const Center(
                child: Text('No se pudo cargar el viaje'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
