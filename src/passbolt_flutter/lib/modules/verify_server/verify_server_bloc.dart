// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:passbolt_flutter/common/input/input_checker.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_api.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_entities.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_interactor.dart';

abstract class BaseVerifyServerBloc implements Bloc<BlocState> {}

class VerifyServerBloc extends DefaultBloc<BlocState>
    implements BaseVerifyServerBloc {
  final BaseVerifyServerInteractor _interactor;
  final _logger = Logger("VerifyServerBloc");

  VerifyServerBloc(this._interactor) {
    this.actions[CheckIntent] = (intent) async {
      if (state is PendingState) {
        _logger.fine("Bloc is in pending state. Return.");
        return;
      }

      setState(PendingState());

      final checkIntent = intent as CheckIntent;

      try {
        await _interactor.checkPassboltServer(
          CheckPassboltServerUserData(
            InputChecker.checkAndTryRepairUrl(checkIntent.url),
            InputChecker.checkAndTryRepairFingerprint(checkIntent.fingerprint),
          ),
        );

        setState(VerifyServerState());
        setReaction(NavigateToImportKeyReaction());
      } catch (error) {
        setState(VerifyServerState());

        String errorMessage;

        if (error is AppException) {
          errorMessage = error.message;
        } else {
          errorMessage = error.toString();
        }

        setReaction(ErrorReaction(errorMessage));
      }
    };
  }
}
