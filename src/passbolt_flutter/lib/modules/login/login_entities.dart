// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetInitStateEvent extends LoginEvent {}

class LoginWithPassphraseEvent extends LoginEvent {
  final String passphrase;

  LoginWithPassphraseEvent(this.passphrase);

  bool validate() {
    return passphrase != null && passphrase.isNotEmpty;
  }
}

class LoginWithBiometryEvent extends LoginEvent {}

class DeleteCurrentServerDataEvent extends LoginEvent {}

class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class PendingInitialLoginState extends LoginState {}

class PendingLoginState extends LoginState {}

class InitialLoginState extends LoginState {
  final String userName;
  final bool isLoginWithBiometricsEnabled;

  InitialLoginState(this.userName, this.isLoginWithBiometricsEnabled);
  
  @override
  List<Object> get props => [userName, isLoginWithBiometricsEnabled];
}

class StartLoginState extends LoginState {}

class NeedAutofillValuesState extends LoginState {}

class SuccessfulLoginState extends LoginState {}

class DeleteCurrentServerDataState extends LoginState {}

class ErrorLoginState extends LoginState {
  final String message;

  ErrorLoginState(this.message);

  @override
  List<Object> get props => [message];
}
