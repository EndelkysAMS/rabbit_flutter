import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLineSubscription.dart';
import 'package:rabbit_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:rabbit_flutter/src/domain/useCases/super-admin/SuperAdminUseCases.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_event.dart';
import 'package:rabbit_flutter/src/presentation/pages/super/dashboard/bloc/super_dashboard_state.dart';

class SuperDashboardBloc
    extends Bloc<SuperDashboardEvent, SuperDashboardState> {
  final SuperAdminUseCases superAdminUseCases;
  final AuthUseCases authUseCases;

  SuperDashboardBloc(this.superAdminUseCases, this.authUseCases)
      : super(const SuperDashboardState()) {
    on<SuperDashboardInitEvent>((event, emit) async {
      final authResponse = await authUseCases.getUserSession.run();
      if (authResponse != null) {
        emit(state.copyWith(superUser: authResponse.user));
      }
      add(LoadSuperLinesEvent());
    });

    on<LoadSuperLinesEvent>((event, emit) async {
      emit(state.copyWith(responseLines: Loading()));
      final response = await superAdminUseCases.getLines();
      if (response is Success<List<SuperLine>>) {
        emit(state.copyWith(
          responseLines: response,
          lines: response.data,
          didLogout: false,
        ));
      } else if (response is ErrorData) {
        final err = response as ErrorData;
        if (err.message.toLowerCase().contains('401')) {
          add(LogoutSuperEvent());
        } else {
          emit(state.copyWith(responseLines: response, didLogout: false));
        }
      } else {
        emit(state.copyWith(responseLines: response, didLogout: false));
      }
    });

    on<ActivateSuperLineEvent>((event, emit) async {
      emit(state.copyWith(responseAction: Loading()));
      final response = await superAdminUseCases.activateLine(event.lineId);
      await _emitActionResult(emit, response, event.lineId);
    });

    on<SuspendSuperLineEvent>((event, emit) async {
      emit(state.copyWith(responseAction: Loading()));
      final response = await superAdminUseCases.suspendLine(event.lineId);
      await _emitActionResult(emit, response, event.lineId);
    });

    on<RecordSuperLinePaymentEvent>((event, emit) async {
      emit(state.copyWith(responseAction: Loading()));
      final response = await superAdminUseCases.recordPayment(
        lineId: event.lineId,
        plan: event.plan,
        notes: event.notes,
      );
      await _emitActionResult(emit, response, event.lineId);
    });

    on<PatchSuperLineSubscriptionEvent>((event, emit) async {
      emit(state.copyWith(responseAction: Loading()));
      final response = await superAdminUseCases.patchSubscription(
        lineId: event.lineId,
        plan: event.plan,
        status: event.status,
        notes: event.notes,
      );
      await _emitActionResult(emit, response, event.lineId);
    });

    on<DeleteSuperLineEvent>((event, emit) async {
      emit(state.copyWith(
        responseAction: Loading(),
        clearLastDeletedLineId: true,
      ));
      final response = await superAdminUseCases.deleteLine(event.lineId);
      if (response is Success<bool>) {
        emit(state.copyWith(
          responseAction: response,
          lines: state.lines.where((l) => l.id != event.lineId).toList(),
          lastDeletedLineId: event.lineId,
          didLogout: false,
        ));
      } else if (response is ErrorData) {
        final err = response as ErrorData;
        if (err.message.toLowerCase().contains('401')) {
          add(LogoutSuperEvent());
        } else {
          emit(state.copyWith(responseAction: response, didLogout: false));
        }
      } else {
        emit(state.copyWith(responseAction: response, didLogout: false));
      }
    });

    on<ClearSuperActionResponseEvent>((event, emit) {
      emit(state.copyWith(responseAction: null, clearLastDeletedLineId: true));
    });

    on<LogoutSuperEvent>((event, emit) async {
      await authUseCases.logout.run();
      emit(state.copyWith(didLogout: true));
    });
  }

  Future<void> _emitActionResult(
    Emitter<SuperDashboardState> emit,
    Resource<SuperLineSubscription> response,
    int lineId,
  ) async {
    if (response is Success<SuperLineSubscription>) {
      final updatedLines = state.lines.map((line) {
        if (line.id != lineId) return line;
        return SuperLine(
          id: line.id,
          name: line.name,
          createdAt: line.createdAt,
          updatedAt: line.updatedAt,
          subscription: response.data,
        );
      }).toList();
      emit(state.copyWith(
        responseAction: response,
        lines: updatedLines,
        didLogout: false,
      ));
      add(LoadSuperLinesEvent());
    } else if (response is ErrorData) {
      final err = response as ErrorData;
      if (err.message.toLowerCase().contains('401')) {
        add(LogoutSuperEvent());
      } else {
        emit(state.copyWith(responseAction: response, didLogout: false));
      }
    } else {
      emit(state.copyWith(responseAction: response, didLogout: false));
    }
  }
}
