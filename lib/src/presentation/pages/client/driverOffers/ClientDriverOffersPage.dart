import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:rabbit_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/ClientDriverOffersItem.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersBloc.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersState.dart';

class ClientDriverOffersPage extends StatefulWidget {
  const ClientDriverOffersPage({super.key});

  @override
  State<ClientDriverOffersPage> createState() => _ClientDriverOffersPageState();
}

class _ClientDriverOffersPageState extends State<ClientDriverOffersPage> {
  int? idClientRequest;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    final parsedId =
        _parseClientRequestId(ModalRoute.of(context)?.settings.arguments);
    if (parsedId == null || parsedId <= 0) {
      Fluttertoast.showToast(
        msg: 'No se pudo obtener id de solicitud',
        toastLength: Toast.LENGTH_LONG,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
    idClientRequest = parsedId;
    context.read<ClientDriverOffersBloc>().add(
          ListenNewDriverOfferSocketIO(idClientRequest: idClientRequest!),
        );
    context.read<ClientDriverOffersBloc>().add(
          GetDriverOffers(idClientRequest: idClientRequest!),
        );
    _isInitialized = true;
  }

  int? _parseClientRequestId(dynamic args) {
    if (args == null) return null;
    if (args is int) return args;
    if (args is Map<String, dynamic>) {
      final raw =
          args['idClientRequest'] ?? args['id_client_request'] ?? args['id'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '');
    }
    return int.tryParse(args.toString());
  }

  @override
  void dispose() {
    context
        .read<ClientDriverOffersBloc>()
        .add(StopListenNewDriverOfferSocketIO());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    idClientRequest ??=
        _parseClientRequestId(ModalRoute.of(context)?.settings.arguments);
    return Scaffold(
      body: BlocListener<ClientDriverOffersBloc, ClientDriverOffersState>(
        listener: (context, state) {
          final response = state.responseDriverOffers;
          final responseAssignDriver = state.responseAssignDriver;
          if (response is ErrorData) {
            Fluttertoast.showToast(
                msg: response.message, toastLength: Toast.LENGTH_LONG);
          }
          if (responseAssignDriver is Success) {
            Navigator.pushNamed(context, 'client/map/trip',
                arguments: idClientRequest);
          }
        },
        child: BlocBuilder<ClientDriverOffersBloc, ClientDriverOffersState>(
            builder: (context, state) {
          final response = state.responseDriverOffers;

          if (response is Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (response is Success) {
            List<DriverTripRequest> driverTripRequest =
                response.data as List<DriverTripRequest>;
            if (driverTripRequest.isEmpty) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Esperando conductores...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Lottie.asset(
                      'assets/lottie/waiting_motorbike.json',
                      width: 400,
                      height: 230,
                    )
                  ],
                ),
              );
            }
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Oferta del conductor',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Revisa y acepta para iniciar el viaje',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                        itemCount: driverTripRequest.length,
                        itemBuilder: (context, index) {
                          return ClientDriverOffersItem(
                              driverTripRequest[index]);
                        }),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Esperando conductores...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Lottie.asset(
                  'assets/lottie/waiting_motorbike.json',
                  width: 400,
                  height: 230,
                  // fit: BoxFit.fill,
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
