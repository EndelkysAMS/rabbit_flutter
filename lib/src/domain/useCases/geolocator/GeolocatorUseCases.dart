import 'package:rabbit_flutter/src/domain/useCases/geolocator/CreateMarkerFromNetworkUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/CreateMarkerUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/FindPositionUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GetMarketUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GetPlacemarkDataUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GetPolylineUseCase.dart';
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GetPositionStreamUseCase.dart';

class GeolocatorUseCases {

  FindPositionUseCase findPosition;
  CreateMarkerUseCase createMarker;
  CreateMarkerFromNetworkUseCase createMarkerFromNetwork;
  GetMarkerUseCase getMarker;
  GetPlacemarkDataUseCase getPlacemarkData;
  GetPolylineUseCase getPolyline;
  GetPositionStreamUseCase getPositionStream;

  GeolocatorUseCases({
    required this.findPosition,
    required this.createMarker,
    required this.createMarkerFromNetwork,
    required this.getMarker,
    required this.getPlacemarkData,
    required this.getPolyline,
    required this.getPositionStream,
  });

}