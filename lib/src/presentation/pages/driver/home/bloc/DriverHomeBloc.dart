import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/home/bloc/DriverHomeEvent.dart';
import 'package:rabbit_flutter/src/presentation/pages/driver/home/bloc/DriverHomeState.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {

  AuthUseCases authUseCases;

  DriverHomeBloc(this.authUseCases): super(DriverHomeState()) {
    on<ChangeDrawerPage>((event, emit) {
      emit(
        state.copyWith(
          pageIndex: event.pageIndex
        )
      );
    });

    on<Logout>((event, emit) async {
      await authUseCases.logout.run();
    });
  }

}