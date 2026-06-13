import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/models/AuthResponse.dart';
import 'package:rabbit_flutter/src/domain/useCases/admin-linea/AdminLineaUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/admin/dashboard/bloc/admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminLineaUseCases adminLineaUseCases;
  final AuthUseCases authUseCases;

  AdminDashboardBloc(this.adminLineaUseCases, this.authUseCases)
      : super(const AdminDashboardState()) {
    on<AdminDashboardInitEvent>((event, emit) async {
      final authResponse = await authUseCases.getUserSession.run();
      if (authResponse != null) {
        emit(state.copyWith(adminUser: authResponse.user));
      }
      add(LoadDriversEvent());
    });

    on<LoadDriversEvent>((event, emit) async {
      emit(state.copyWith(responseDrivers: Loading()));
      final response = await adminLineaUseCases.getDrivers.run();
      if (response is Success) {
        emit(state.copyWith(
            responseDrivers: response, drivers: response.data, didLogout: false));
      } else if (response is ErrorData &&
          response.message.toLowerCase().contains('401')) {
        add(LogoutAdminEvent());
      } else {
        emit(state.copyWith(responseDrivers: response, didLogout: false));
      }
    });

    on<LoadInactiveDriversEvent>((event, emit) async {
      emit(state.copyWith(responseInactiveDrivers: Loading()));
      final response =
          await adminLineaUseCases.getDrivers.run(isActive: false);
      if (response is Success) {
        emit(state.copyWith(
          responseInactiveDrivers: response,
          inactiveDrivers: response.data,
          didLogout: false,
        ));
      } else if (response is ErrorData &&
          response.message.toLowerCase().contains('401')) {
        add(LogoutAdminEvent());
      } else {
        emit(state.copyWith(
            responseInactiveDrivers: response, didLogout: false));
      }
    });

    on<CreateDriverEvent>((event, emit) async {
      emit(state.copyWith(responseCreateDriver: Loading()));
      final response =
          await adminLineaUseCases.createDriver.run(event.createDriver);
      emit(state.copyWith(responseCreateDriver: response));
      if (response is Success) {
        add(LoadDriversEvent());
      } else if (response is ErrorData &&
          response.message.toLowerCase().contains('401')) {
        add(LogoutAdminEvent());
      }
    });

    on<DeactivateDriverEvent>((event, emit) async {
      emit(state.copyWith(responseDeactivateDriver: Loading()));
      final response =
          await adminLineaUseCases.deactivateDriver.run(event.idDriver);
      emit(state.copyWith(responseDeactivateDriver: response));
      if (response is Success) {
        add(LoadDriversEvent());
        add(LoadInactiveDriversEvent());
      } else if (response is ErrorData &&
          response.message.toLowerCase().contains('401')) {
        add(LogoutAdminEvent());
      }
    });

    on<DeleteDriverEvent>((event, emit) async {
      emit(state.copyWith(responseDeleteDriver: Loading()));
      final response =
          await adminLineaUseCases.deleteDriver.run(event.idDriver);
      emit(state.copyWith(responseDeleteDriver: response));
      if (response is Success) {
        add(LoadInactiveDriversEvent());
      } else if (response is ErrorData &&
          response.message.toLowerCase().contains('401')) {
        add(LogoutAdminEvent());
      }
    });

    on<ClearDeleteDriverResponseEvent>((event, emit) {
      emit(state.copyWith(responseDeleteDriver: null));
    });

    on<UpdateAdminProfileEvent>((event, emit) async {
      emit(state.copyWith(responseUpdateProfile: Loading()));
      final response =
          await adminLineaUseCases.updateProfile.run(event.profile);
      emit(state.copyWith(responseUpdateProfile: response));
      if (response is Success) {
        final AuthResponse? authResponse =
            await authUseCases.getUserSession.run();
        if (authResponse != null) {
          authResponse.user.name = event.profile.name;
          authResponse.user.lastname = event.profile.lastname;
          authResponse.user.phone = event.profile.phone;
          authResponse.user.image = event.profile.image;
          await authUseCases.saveUserSession.run(authResponse);
          emit(state.copyWith(adminUser: authResponse.user));
        }
      } else if (response is ErrorData &&
          response.message.toLowerCase().contains('401')) {
        add(LogoutAdminEvent());
      }
    });

    on<ClearCreateDriverResponseEvent>((event, emit) {
      emit(state.copyWith(responseCreateDriver: null));
    });

    on<ClearDeactivateDriverResponseEvent>((event, emit) {
      emit(state.copyWith(responseDeactivateDriver: null));
    });

    on<ClearUpdateProfileResponseEvent>((event, emit) {
      emit(state.copyWith(responseUpdateProfile: null));
    });

    on<LogoutAdminEvent>((event, emit) async {
      await authUseCases.logout.run();
      emit(state.copyWith(didLogout: true));
    });
  }
}
