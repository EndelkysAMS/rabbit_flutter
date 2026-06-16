import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/ClientMapTripContent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapTrip/bloc/ClientMapTripState.dart';

class ClientMapTripPage extends StatefulWidget {
  const ClientMapTripPage({super.key});

  @override
  State<ClientMapTripPage> createState() => _ClientMapTripPageState();
}

class _ClientMapTripPageState extends State<ClientMapTripPage> {
  int? idClientRequest;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final parsedId = args is int ? args : int.tryParse(args?.toString() ?? '');
    if (parsedId == null || parsedId <= 0) return;
    idClientRequest = parsedId;
    final bloc = context.read<ClientMapTripBloc>();
    bloc.add(InitClientMapTripEvent());
    bloc.add(GetClientRequest(idClientRequest: parsedId));
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ClientMapTripBloc, ClientMapTripState>(
        listener: (context, state) {
          final responseClientRequest = state.responseGetClientRequest;

          if (responseClientRequest is ErrorData) {
            Fluttertoast.showToast(
                msg: responseClientRequest.message,
                toastLength: Toast.LENGTH_LONG);
          }
        },
        child: BlocBuilder<ClientMapTripBloc, ClientMapTripState>(
          builder: (context, state) {
            final responseClientRequest = state.responseGetClientRequest;
            if (responseClientRequest is Success) {
              final data = responseClientRequest.data as ClientRequestResponse;

              return ClientMapTripContent(state, data);
            }
            return Container();
          },
        ),
      ),
    );
  }
}
