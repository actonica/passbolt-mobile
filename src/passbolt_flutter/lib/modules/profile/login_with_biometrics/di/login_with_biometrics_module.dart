// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/login_with_biometrics_bloc.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/login_with_biometrics_entities.dart';

@module
class LoginWithBiometricsDiModule {
  final LoginWithBiometricsModuleIn _moduleIn;

  LoginWithBiometricsDiModule(this._moduleIn);

  @provide
  @singleton
  BaseLoginWithBiometricsBloc bloc(
    LoginWithBiometricsModuleIn moduleIn,
    BaseSettingsProvider settingsProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BasePassphraseProvider passphraseProvider,
  ) =>
      LoginWithBiometricsBloc(
        moduleIn,
        settingsProvider,
        secureStorageProvider,
        passphraseProvider,
      );

  @provide
  @singleton
  LoginWithBiometricsModuleIn moduleIn() => this._moduleIn;
}
