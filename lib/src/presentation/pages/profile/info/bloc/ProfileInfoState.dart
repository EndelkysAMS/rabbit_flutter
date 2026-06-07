import 'package:equatable/equatable.dart';
import 'package:rabbit_flutter/src/domain/models/user.dart';

class ProfileInfoState extends Equatable {
  final User? user;
  final bool didLogout;

  ProfileInfoState({this.user, this.didLogout = false});

  ProfileInfoState copyWith({
    User? user,
    bool? didLogout,
  }) {
    return ProfileInfoState(
      user: user ?? this.user,
      didLogout: didLogout ?? this.didLogout,
    );
  }

  @override
  List<Object?> get props => [user, didLogout];
}
