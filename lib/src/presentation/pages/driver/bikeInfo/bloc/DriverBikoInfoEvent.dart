import 'package:rabbit_flutter/src/presentation/utils/BlocFormItem.dart';

abstract class DriverBikeInfoEvent {}

class DriverBikeInfoInitEvent extends DriverBikeInfoEvent {}

class BrandChanged extends DriverBikeInfoEvent {
  final BlocFormItem brand;
  BrandChanged({ required this.brand });
}

class PlateChanged extends DriverBikeInfoEvent {
  final BlocFormItem plate;
  PlateChanged({ required this.plate });
}

class ColorChanged extends DriverBikeInfoEvent {
  final BlocFormItem color;
  ColorChanged({ required this.color });
}

class FormSubmit extends DriverBikeInfoEvent {}