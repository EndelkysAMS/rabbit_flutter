import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

class DriverBikeInfoState extends Equatable {
  final int? idDriver;
  final BlocFormItem brand;
  final BlocFormItem plate;
  final BlocFormItem color;
  final Resource? response;
  final GlobalKey<FormState>? formKey;
  final bool isInitialized;

  const DriverBikeInfoState({
    this.idDriver,
    this.brand = const BlocFormItem(error: 'Ingresa la marca de la moto'),
    this.plate = const BlocFormItem(error: 'Ingresa la placa de la moto'),
    this.color = const BlocFormItem(error: 'Ingresa el color de la moto'),
    this.formKey,
    this.response,
    this.isInitialized = false,
  });

  DriverBikeInfoState copyWith({
    int? idDriver,
    BlocFormItem? brand,
    BlocFormItem? plate,
    BlocFormItem? color,
    GlobalKey<FormState>? formKey,
    Resource? response,
    bool clearResponse = false,
    bool? isInitialized,
  }) {
    return DriverBikeInfoState(
      idDriver: idDriver ?? this.idDriver,
      brand: brand ?? this.brand,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      formKey: formKey,
      response: clearResponse ? null : (response ?? this.response),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props =>
      [brand, plate, color, response, idDriver, isInitialized];
}
