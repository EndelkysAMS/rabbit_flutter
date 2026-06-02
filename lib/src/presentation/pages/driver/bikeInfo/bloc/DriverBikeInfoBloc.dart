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

  DriverBikeInfoBloc(this.authUseCases, this.driverBikeInfoUseCases): super(DriverBikeInfoState()) {
    
    on<DriverBikeInfoInitEvent>((event, emit) async {
      emit(
        state.copyWith(
          formKey: formKey
        )
      );
      AuthResponse  authResponse = await authUseCases.getUserSession.run();
      Resource response = await driverBikeInfoUseCases.getDriverBikeInfo.run(authResponse.user.id!);
      if (response is Success) {
        final driverBikeInfo = response.data as DriverBikeInfo;
         emit(
          state.copyWith(
            idDriver: authResponse.user.id!,
            brand: BlocFormItem(
              value: driverBikeInfo.brand
            ),
            plate: BlocFormItem(
              value: driverBikeInfo.plate
            ),
            color: BlocFormItem(
              value: driverBikeInfo.color
            ),
            formKey: formKey
          )
        );
      }
     
    });
    on<BrandChanged>((event, emit) {
      emit(
        state.copyWith(
          brand: BlocFormItem(
            value: event.brand.value,
            error: event.brand.value.isEmpty ? 'Ingresa la marca de la moto' : null
          ),
          formKey: formKey
        )
      );
    });
    on<PlateChanged>((event, emit) {
      emit(
        state.copyWith(
          plate: BlocFormItem(
            value: event.plate.value,
            error: event.plate.value.isEmpty ? 'Ingresa la placa de la moto' : null
          ),
          formKey: formKey
        )
      );
    });
    on<ColorChanged>((event, emit) {
      emit(
        state.copyWith(
          color: BlocFormItem(
            value: event.color.value,
            error: event.color.value.isEmpty ? 'Ingresa el color de la moto' : null
          ),
          formKey: formKey
        )
      );
    });
    
    on<FormSubmit>((event, emit) async {
      emit(
        state.copyWith(
          response: Loading(),
          formKey: formKey
        )
      );
      Resource response = await driverBikeInfoUseCases.createDriverBikeInfo.run(
        DriverBikeInfo(
          idDriver: state.idDriver,
          brand: state.brand.value, 
          plate: state.plate.value, 
          color: state.color.value
        )
      );
      emit(
        state.copyWith(
          response: response,
          formKey: formKey
        )
      );
    });
  }

}