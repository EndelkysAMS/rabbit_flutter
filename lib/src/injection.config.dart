// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:rabbit_flutter/src/data/dataSource/local/SharefPref.dart'
    as _i858;
import 'package:rabbit_flutter/src/data/dataSource/remote/services/AuthService.dart'
    as _i565;
import 'package:rabbit_flutter/src/data/dataSource/remote/services/ClientRequestsService.dart'
    as _i394;
import 'package:rabbit_flutter/src/data/dataSource/remote/services/DriverBikeInfoService.dart'
    as _i691;
import 'package:rabbit_flutter/src/data/dataSource/remote/services/DriversPositionService.dart'
    as _i156;
import 'package:rabbit_flutter/src/data/dataSource/remote/services/DriverTripRequestsService.dart'
    as _i959;
import 'package:rabbit_flutter/src/data/dataSource/remote/services/UsersService.dart'
    as _i218;
import 'package:rabbit_flutter/src/data/repository/DriverBikeInfoRepository.dart'
    as _i920;
import 'package:rabbit_flutter/src/di/AppModule.dart' as _i581;
import 'package:rabbit_flutter/src/domain/repository/AuthRepository.dart'
    as _i972;
import 'package:rabbit_flutter/src/domain/repository/ClientRequestsRepository.dart'
    as _i116;
import 'package:rabbit_flutter/src/domain/repository/DriversPositionRepository.dart'
    as _i80;
import 'package:rabbit_flutter/src/domain/repository/DriverTripRequestsRepository.dart'
    as _i824;
import 'package:rabbit_flutter/src/domain/repository/GeolocatorRepository.dart'
    as _i96;
import 'package:rabbit_flutter/src/domain/repository/SocketRepository.dart'
    as _i307;
import 'package:rabbit_flutter/src/domain/repository/UsersRepository.dart'
    as _i298;
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart'
    as _i811;
import 'package:rabbit_flutter/src/domain/useCases/client-requests/ClientRequestsUseCases.dart'
    as _i821;
import 'package:rabbit_flutter/src/domain/useCases/driver-bike-info/DriverBikeInfoUseCases.dart'
    as _i299;
import 'package:rabbit_flutter/src/domain/useCases/driver-trip-request/DriverTripRequestUseCases.dart'
    as _i969;
import 'package:rabbit_flutter/src/domain/useCases/drivers-position/DriversPositionUseCases.dart'
    as _i103;
import 'package:rabbit_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart'
    as _i512;
import 'package:rabbit_flutter/src/domain/useCases/socket/SocketUseCases.dart'
    as _i458;
import 'package:rabbit_flutter/src/domain/useCases/users/UsersUseCases.dart'
    as _i61;
import 'package:socket_io_client/socket_io_client.dart' as _i414;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.factory<_i858.SharefPref>(() => appModule.sharefPref);
    gh.factory<_i414.Socket>(() => appModule.socket);
    gh.factoryAsync<String>(() => appModule.token);
    gh.factory<_i565.AuthService>(() => appModule.authService);
    gh.factory<_i218.UsersService>(() => appModule.usersService);
    gh.factory<_i156.DriversPositionService>(
      () => appModule.driversPositionService,
    );
    gh.factory<_i394.ClientRequestsService>(
      () => appModule.clientRequestsService,
    );
    gh.factory<_i959.DriverTripRequestsService>(
      () => appModule.driverTripRequestsService,
    );
    gh.factory<_i691.DriverBikeInfoService>(
      () => appModule.driverBikeInfoService,
    );
    gh.factory<_i972.AuthRepository>(() => appModule.authRepository);
    gh.factory<_i298.UsersRepository>(() => appModule.usersRepository);
    gh.factory<_i307.SocketRepository>(() => appModule.socketRepository);
    gh.factory<_i116.ClientRequestsRepository>(
      () => appModule.clientRequestsRepository,
    );
    gh.factory<_i96.GeolocatorRepository>(() => appModule.geolocatorRepository);
    gh.factory<_i80.DriverPositionRepository>(
      () => appModule.driversPositionRepository,
    );
    gh.factory<_i824.DriverTripRequestsRepository>(
      () => appModule.driverTripRequestsRepository,
    );
    gh.factory<_i920.DriverBikeInfoRepository>(
      () => appModule.driverBikeInfoRepository,
    );
    gh.factory<_i811.AuthUseCases>(() => appModule.authUseCases);
    gh.factory<_i61.UsersUseCases>(() => appModule.usersUseCases);
    gh.factory<_i512.GeolocatorUseCases>(() => appModule.geolocatorUseCases);
    gh.factory<_i458.SocketUseCases>(() => appModule.socketUseCases);
    gh.factory<_i103.DriversPositionUseCases>(
      () => appModule.driversPositionUseCases,
    );
    gh.factory<_i821.ClientRequestsUseCases>(
      () => appModule.clientRequestsUseCases,
    );
    gh.factory<_i969.DriverTripRequestUseCases>(
      () => appModule.driverTripRequestUseCases,
    );
    gh.factory<_i299.DriverBikeInfoUseCases>(
      () => appModule.driverCarInfoUseCases,
    );
    return this;
  }
}

class _$AppModule extends _i581.AppModule {}
