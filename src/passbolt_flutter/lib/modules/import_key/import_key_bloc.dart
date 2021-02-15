// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/modules/import_key/import_key_entities.dart';
import 'package:passbolt_flutter/modules/import_key/import_key_interactor.dart';

abstract class BaseImportKeyBloc implements Bloc<BlocState> {}

class ImportKeyBloc extends DefaultBloc<BlocState>
    implements BaseImportKeyBloc {
  final BaseImportKeyInteractor _interactor;
  final _logger = Logger("ImportKeyBloc");

  ImportKeyBloc(this._interactor) {
    this.actions[ImportKeyIntent] = (intent) async {
      final importKeyIntent = intent as ImportKeyIntent;
      final String privateKey = importKeyIntent.privateKey;

      if (privateKey == null || privateKey.isEmpty) {
        setReaction(ErrorReaction('Input your private key, please.'));
      } else {
        await _interactor.setPrivateKey(privateKey);
        setReaction(NavigateToLoginReaction());
      }
    };
  }
}
