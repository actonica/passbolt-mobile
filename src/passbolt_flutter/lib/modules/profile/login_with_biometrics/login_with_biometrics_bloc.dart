// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:biometrics_vault/biometrics_vault.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/app/app_assembly.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/login_with_biometrics_entities.dart';
import 'package:uuid/uuid.dart';

abstract class BaseLoginWithBiometricsBloc implements Bloc<BlocState> {}

class LoginWithBiometricsBloc extends DefaultBloc<BlocState>
    implements BaseLoginWithBiometricsBloc {
  final LoginWithBiometricsModuleIn _moduleIn;
  final BaseSettingsProvider _settingsProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BasePassphraseProvider _passphraseProvider;
  final _logger = Logger('LoginWithBiometricsBloc');

  LoginWithBiometricsBloc(
    this._moduleIn,
    this._settingsProvider,
    this._secureStorageProvider,
    this._passphraseProvider,
  ) {
    this.actions[ChangeLoginWithBiometricsIntent] = (intent) async {
      try {
        final changeIntent = intent as ChangeLoginWithBiometricsIntent;
        if (this.state is LoginWithBiometricsState &&
            (this.state as LoginWithBiometricsState).currentValue ==
                changeIntent.value) {
          return;
        }

        final instructions = 'Authenticate with biometrics';

        if (changeIntent.value) {
          final aliasForPassphraseKey = Uuid().v1();
          final setSecretResult = await BiometricsVault.setSecretWithBiometrics(
            instructions: instructions,
            key: aliasForPassphraseKey,
            clear: _passphraseProvider.passphrase,
            accessGroupId: AppAssembly.accessGroupId,
          );

          if (setSecretResult == BiometricsVaultResult.success) {
            await _secureStorageProvider.setProperty(
              SecureStorageKey.ALIAS_FOR_PASSPHRASE_KEY,
              aliasForPassphraseKey,
            );
          } else {
            throw AppException(setSecretResult);
          }
        } else {
          final aliasForPassphraseKey = await _secureStorageProvider
              .getProperty(SecureStorageKey.ALIAS_FOR_PASSPHRASE_KEY);
          await BiometricsVault.deleteSecretWithBiometrics(
            instructions: instructions,
            key: aliasForPassphraseKey,
            accessGroupId: AppAssembly.accessGroupId,
          );

          await _secureStorageProvider.deleteProperty(
            SecureStorageKey.ALIAS_FOR_PASSPHRASE_KEY,
          );
        }

        await _settingsProvider.setProperty(
          SettingsKey.loginWithBiometrics,
          changeIntent.value,
        );

        setState(LoginWithBiometricsState(changeIntent.value));
      } catch (error) {
        String errorMessage;
        if (error is PlatformException) {
          errorMessage = '${error.code}. ${error.message ?? ''}';
        } else if (error is AppException) {
          errorMessage = error.message;
        } else {
          errorMessage = error.toString();
        }

        setReaction(ErrorReaction(errorMessage));
      }
    };

    setState(LoginWithBiometricsState(_moduleIn.currentValue));
  }
}
