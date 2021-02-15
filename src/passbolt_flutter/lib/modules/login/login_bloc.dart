// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/modules/login/login_entities.dart';
import 'package:passbolt_flutter/modules/login/login_interactor.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final BaseLoginInteractor _interactor;
  final _logger = Logger("LoginBloc");

  LoginBloc(this._interactor) : super(PendingInitialLoginState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    try {
      if (event is GetInitStateEvent) {
        String userName = await _interactor.getUserName();
        bool isLoginWithBiometricsEnabled =
            await _interactor.isLoginWithBiometricsEnabled();

        yield InitialLoginState(userName, isLoginWithBiometricsEnabled);

        if (isLoginWithBiometricsEnabled) {
          add(LoginWithBiometryEvent());
        }
      } else if (event is LoginWithPassphraseEvent) {
        if (state is PendingLoginState) {
          _logger.fine("Bloc is in pending state. Return.");
          return;
        }

        yield PendingLoginState();

        await _interactor.login(
          LoginRequest(
            event.passphrase,
          ),
        );

        final checkAutofillResponse =
            await _interactor.checkAutofill(CheckAutofillRequest());
        if (checkAutofillResponse.hasAutofillHints) {
          yield NeedAutofillValuesState();
        } else {
          yield SuccessfulLoginState();
        }
      } else if (event is LoginWithBiometryEvent) {
        if (state is PendingLoginState) {
          _logger.fine("Bloc is in pending state. Return.");
          return;
        }

        yield PendingLoginState();

        await _interactor.loginWithBiometrics();
        final checkAutofillResponse =
            await _interactor.checkAutofill(CheckAutofillRequest());
        if (checkAutofillResponse.hasAutofillHints) {
          yield NeedAutofillValuesState();
        } else {
          yield SuccessfulLoginState();
        }
      } else if (event is DeleteCurrentServerDataEvent) {
        await _interactor.deleteCurrentServerData();
        yield DeleteCurrentServerDataState();
      }
    } on dynamic catch (e) {
      yield ErrorLoginState(e.toString());
    }
  }
}
