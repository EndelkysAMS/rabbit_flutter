import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rabbit_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/ClientRequest.dart';
import 'package:rabbit_flutter/src/domain/models/TimeAndDistanceValues.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBookingInfoState.dart';
import 'package:rabbit_flutter/src/presentation/pages/client/mapBookingInfo/bloc/ClientMapBoolingInfoEvent.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class ClientMapBookingInfoBloc
    extends Bloc<ClientMapBookingInfoEvent, ClientMapBookingInfoState> {
  GeolocatorUseCases geolocatorUseCases;
  ClientRequestsUseCases clientRequestsUseCases;
  AuthUseCases authUseCases;
  BlocSocketIO blocSocketIO;

  ClientMapBookingInfoBloc(this.blocSocketIO, this.geolocatorUseCases,
      this.clientRequestsUseCases, this.authUseCases)
      : super(ClientMapBookingInfoState()) {
    on<ClientMapBookingInfoInitEvent>((event, emit) async {
      Completer<GoogleMapController> controller =
          Completer<GoogleMapController>();
      emit(state.copyWith(
        pickUpLatLng: event.pickUpLatLng,
        destinationLatLng: event.destinationLatLng,
        pickUpDescription: event.pickUpDescription,
        destinationDescription: event.destinationDescription,
        controller: controller,
        fareOffered: const BlocFormItem(value: '', error: 'Ingresa la tarifa'),
        responseClientRequest: null,
      ));
      BitmapDescriptor pickUpDescriptor =
          await geolocatorUseCases.createMarker.run('assets/img/pin.png');
      BitmapDescriptor destinationDescriptor =
          await geolocatorUseCases.createMarker.run('assets/img/red-flag.png');
      Marker markerPickUp = geolocatorUseCases.getMarker.run(
        'pickup',
        state.pickUpLatLng!.latitude,
        state.pickUpLatLng!.longitude,
        'Lugar de recogida',
        'Debes permancer aqui mientras llega el conductor',
        pickUpDescriptor,
        anchor: const Offset(0.5, 1.0),
      );
      Marker markerDestination = geolocatorUseCases.getMarker.run(
        'destination',
        state.destinationLatLng!.latitude,
        state.destinationLatLng!.longitude,
        'Tu Destino',
        '',
        destinationDescriptor,
        anchor: const Offset(0.5, 1.0),
      );
      emit(state.copyWith(markers: {
        markerPickUp.markerId: markerPickUp,
        markerDestination.markerId: markerDestination
      }));
      add(GetTimeAndDistanceValues());
      add(AddPolyline());
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      GoogleMapController googleMapController = await state.controller!.future;
      await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(event.lat, event.lng), zoom: 12, bearing: 0)));
    });

    on<FareOfferedChanged>((event, emit) {
      emit(state.copyWith(
          fareOffered: BlocFormItem(
              value: event.fareOffered.value,
              error: event.fareOffered.value.isEmpty
                  ? 'Ingresa la tarifa'
                  : null)));
    });

    on<CreateClientRequest>((event, emit) async {
      AuthResponse authResponse = await authUseCases.getUserSession.run();
      final fareValue = double.tryParse(
        state.fareOffered.value.trim().replaceAll(',', '.'),
      );
      if (fareValue == null || fareValue <= 0) {
        emit(
          state.copyWith(
            responseClientRequest: ErrorData('Ingresa una tarifa valida'),
          ),
        );
        return;
      }

      Resource<int> response = await clientRequestsUseCases.createClientRequest
          .run(ClientRequest(
              idClient: authResponse.user.id!,
              fareOffered: fareValue,
              pickupDescription: state.pickUpDescription,
              destinationDescription: state.destinationDescription,
              pickupLat: state.pickUpLatLng!.latitude,
              pickupLng: state.pickUpLatLng!.longitude,
              destinationLat: state.destinationLatLng!.latitude,
              destinationLng: state.destinationLatLng!.longitude));

      emit(state.copyWith(responseClientRequest: response));
    });

    on<EmitNewClientRequestSocketIO>((event, emit) {
      if (blocSocketIO.state.socket != null) {
        blocSocketIO.state.socket?.emit(
            'new_client_request', {'id_client_request': event.idClientRequest});
      }
    });

    on<GetTimeAndDistanceValues>((event, emit) async {
      emit(state.copyWith(responseTimeAndDistance: Loading()));
      Resource<TimeAndDistanceValues> response =
          await clientRequestsUseCases.getTimeAndDistance.run(
        state.pickUpLatLng!.latitude,
        state.pickUpLatLng!.longitude,
        state.destinationLatLng!.latitude,
        state.destinationLatLng!.longitude,
      );
      emit(state.copyWith(responseTimeAndDistance: response));
    });
    on<AddPolyline>((event, emit) async {
      final pickUp = state.pickUpLatLng!;
      final destination = state.destinationLatLng!;
      List<LatLng> polylineCoordinates =
          await geolocatorUseCases.getPolyline.run(pickUp, destination);
      PolylineId id = PolylineId("MyRoute");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.orange,
        points: polylineCoordinates,
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      emit(state.copyWith(polylines: {id: polyline}));
      await _fitCameraToRoute(polylineCoordinates, pickUp, destination);
    });

    on<FitRouteCamera>((event, emit) async {
      final pickUp = state.pickUpLatLng;
      final destination = state.destinationLatLng;
      if (pickUp == null || destination == null) return;
      final route = state.polylines[PolylineId('MyRoute')]?.points ?? [];
      await _fitCameraToRoute(route, pickUp, destination);
    });
  }

  Future<void> _fitCameraToRoute(
    List<LatLng> routePoints,
    LatLng pickUp,
    LatLng destination,
  ) async {
    if (state.controller == null || !state.controller!.isCompleted) {
      return;
    }
    final allPoints = [...routePoints, pickUp, destination];
    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;
    for (final point in allPoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    try {
      final controller = await state.controller!.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          80,
        ),
      );
    } catch (e) {
      print('Error fitting camera to route: $e');
    }
  }
}
