import 'package:equatable/equatable.dart';
import 'package:rabbit_flutter/src/domain/models/SuperLine.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';
import 'package:rabbit_flutter/src/domain/utils/Resource.dart';

const _unset = Object();

class SuperDashboardState extends Equatable {
  final User? superUser;
  final List<SuperLine> lines;
  final Resource? responseLines;
  final Resource? responseAction;
  final bool didLogout;
  final int? lastDeletedLineId;

  const SuperDashboardState({
    this.superUser,
    this.lines = const [],
    this.responseLines,
    this.responseAction,
    this.didLogout = false,
    this.lastDeletedLineId,
  });

  int get activeLinesCount =>
      lines.where((l) => l.subscription.status == 'activa').length;

  int get suspendedLinesCount =>
      lines.where((l) => l.subscription.status == 'suspendida').length;

  SuperLine? lineById(int id) {
    for (final line in lines) {
      if (line.id == id) return line;
    }
    return null;
  }

  SuperDashboardState copyWith({
    User? superUser,
    List<SuperLine>? lines,
    Object? responseLines = _unset,
    Object? responseAction = _unset,
    bool? didLogout,
    int? lastDeletedLineId,
    bool clearLastDeletedLineId = false,
  }) {
    return SuperDashboardState(
      superUser: superUser ?? this.superUser,
      lines: lines ?? this.lines,
      responseLines: identical(responseLines, _unset)
          ? this.responseLines
          : responseLines as Resource?,
      responseAction: identical(responseAction, _unset)
          ? this.responseAction
          : responseAction as Resource?,
      didLogout: didLogout ?? this.didLogout,
      lastDeletedLineId: clearLastDeletedLineId
          ? null
          : (lastDeletedLineId ?? this.lastDeletedLineId),
    );
  }

  @override
  List<Object?> get props =>
      [superUser, lines, responseLines, responseAction, didLogout, lastDeletedLineId];
}
