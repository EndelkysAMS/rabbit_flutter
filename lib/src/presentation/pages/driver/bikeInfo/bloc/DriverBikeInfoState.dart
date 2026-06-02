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

  DriverBikeInfoState({
    this.idDriver,
    this.brand = const BlocFormItem(error: 'Ingresa el nombre'),
    this.plate = const BlocFormItem(error: 'Ingresa el apellido'),
    this.color = const BlocFormItem(error: 'Ingresa el telefono'),
    this.formKey,
    this.response,
  });

  DriverBikeInfoState copyWith({
    int? idDriver,
    BlocFormItem? brand,
    BlocFormItem? plate,
    BlocFormItem? color,
    GlobalKey<FormState>? formKey,
    Resource? response
  }) {
    return DriverBikeInfoState(
      idDriver: idDriver ?? this.idDriver,
      brand: brand ?? this.brand,
      plate: plate ?? this.plate,
      color: color ?? this.color,
      formKey: formKey,
      response: response
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [brand, plate, color, response, idDriver];

}