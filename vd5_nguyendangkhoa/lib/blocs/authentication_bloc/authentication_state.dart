part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, unknow }

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknow,
    this.user,
  });
  final AuthenticationStatus status;
  final MyUser? user;

  const AuthenticationState.unknow() : this._();

  const AuthenticationState.authenticated(MyUser myUser)
    : this._(status: AuthenticationStatus.authenticated, user: myUser);
  const AuthenticationState.unauthenticated()
    : this._(status: AuthenticationStatus.unauthenticated);
  @override
  List<Object> get props => [status, ?user];
}