part of 'auth_bloc.dart';

@immutable
class AuthState {

  final UserToken? user;

  const AuthState({
    this.user
  });


  AuthState copyWith({ 
    UserToken? user
  })=> AuthState(
    user: user ?? this.user
  );
  
}

class LoadingAuthState extends AuthState {}

class SuccessAuthState extends AuthState {
  const SuccessAuthState(UserToken user) : super(user: user);
}

class LogOutAuthState extends AuthState {}

class FailureAuthState extends AuthState {
  final error;
  const FailureAuthState(this.error);
}
