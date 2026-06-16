import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/models/DriverBikeInfo.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/driver-bike-info/DriverBikeInfoUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikeInfoState.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/bikeInfo/bloc/DriverBikoInfoEvent.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class DriverBikeInfoBloc extends Bloc<DriverBikeInfoEvent, DriverBikeInfoState> {
  AuthUseCases authUseCases;
  DriverBikeInfoUseCases driverBikeInfoUseCases;
  final formKey = GlobalKey<FormState>();

  DriverBikeInfoBloc(this.authUseCases, this.driverBikeInfoUseCases)
      : super(const DriverBikeInfoState()) {
    on<DriverBikeInfoInitEvent>((event, emit) async {
      emit(state.copyWith(response: Loading(), formKey: formKey));
      final AuthResponse authResponse = await authUseCases.getUserSession.run();
      final idDriver = authResponse.user.id!;
      final response =
          await driverBikeInfoUseCases.getDriverBikeInfo.run(idDriver);

      if (response is Success<DriverBikeInfo>) {
        final driverBikeInfo = response.data;
        emit(state.copyWith(
          idDriver: idDriver,
          brand: BlocFormItem(value: driverBikeInfo.brand),
          plate: BlocFormItem(value: driverBikeInfo.plate),
          color: BlocFormItem(value: driverBikeInfo.color),
          isInitialized: true,
          clearResponse: true,
          formKey: formKey,
        ));
        return;
      }

      emit(state.copyWith(
        idDriver: idDriver,
        brand: const BlocFormItem(value: ''),
        plate: const BlocFormItem(value: ''),
        color: const BlocFormItem(value: ''),
        isInitialized: true,
        clearResponse: true,
        formKey: formKey,
      ));
    });

    on<BrandChanged>((event, emit) {
      emit(
        state.copyWith(
          brand: BlocFormItem(
            value: event.brand.value,
            error: event.brand.value.isEmpty
                ? 'Ingresa la marca de la moto'
                : null,
          ),
          formKey: formKey,
        ),
      );
    });

    on<PlateChanged>((event, emit) {
      emit(
        state.copyWith(
          plate: BlocFormItem(
            value: event.plate.value,
            error:
                event.plate.value.isEmpty ? 'Ingresa la placa de la moto' : null,
          ),
          formKey: formKey,
        ),
      );
    });

    on<ColorChanged>((event, emit) {
      emit(
        state.copyWith(
          color: BlocFormItem(
            value: event.color.value,
            error:
                event.color.value.isEmpty ? 'Ingresa el color de la moto' : null,
          ),
          formKey: formKey,
        ),
      );
    });

    on<FormSubmit>((event, emit) async {
      final idDriver = state.idDriver;
      if (idDriver == null || idDriver <= 0) {
        emit(
          state.copyWith(
            response: ErrorData('No se pudo identificar al conductor'),
            formKey: formKey,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          response: Loading(),
          formKey: formKey,
        ),
      );
      final response = await driverBikeInfoUseCases.createDriverBikeInfo.run(
        DriverBikeInfo(
          idDriver: idDriver,
          brand: state.brand.value.trim(),
          plate: state.plate.value.trim(),
          color: state.color.value.trim(),
        ),
      );
      emit(
        state.copyWith(
          response: response,
          formKey: formKey,
        ),
      );
    });

    on<ClearDriverBikeInfoResponse>((event, emit) {
      emit(state.copyWith(clearResponse: true, formKey: formKey));
    });
  }
}
