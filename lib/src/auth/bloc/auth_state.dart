part of 'auth_cubit.dart';

enum AuthStatus {
  unknown,
  authenticating,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final model.User? user;

  const AuthState({this.status = AuthStatus.unknown, this.user});

  AuthState copyWith({
    AuthStatus? status,
    model.User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}
