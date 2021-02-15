// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:io';

import 'package:autofill/autofill.dart';
import 'package:biometrics_vault/biometrics_vault.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:openpgp/openpgp.dart';
import 'package:passbolt_flutter/analytics/AnalyticsEvents.dart';
import 'package:passbolt_flutter/app/app_assembly.dart';
import 'package:passbolt_flutter/common/decrypt.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/providers/autofill_hints_provider.dart';
import 'package:passbolt_flutter/data/providers/autofill_values_provider.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/modules/login/login_api.dart';
import 'package:pedantic/pedantic.dart';

class LoginRequest {
  final String passphrase;

  LoginRequest(this.passphrase);
}

class CheckAutofillRequest {}

class CheckAutofillResponse {
  final bool hasAutofillHints;

  CheckAutofillResponse(this.hasAutofillHints);
}

abstract class BaseLoginInteractor implements Interactor {
  Future<CheckAutofillResponse> checkAutofill(CheckAutofillRequest request);

  Future<void> deleteCurrentServerData();

  Future<String> getUserName();

  Future<bool> isLoginWithBiometricsEnabled();

  Future<void> login(LoginRequest request);

  Future<void> loginWithBiometrics();
}

class LoginInteractor implements BaseLoginInteractor {
  final BaseLoginApi _loginApi;
  final BaseAutofillHintsProvider _autofillHintsProvider;
  final BaseAutofillValuesProvider _autofillValuesProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BasePassphraseProvider _passphraseProvider;
  final BaseSettingsProvider _settingsProvider;
  final FirebaseAnalytics _firebaseAnalytics;
  final _logger = Logger("LoginInteractor");

  LoginInteractor(
    this._loginApi,
    this._autofillHintsProvider,
    this._autofillValuesProvider,
    this._secureStorageProvider,
    this._passphraseProvider,
    this._settingsProvider,
    this._firebaseAnalytics,
  );

  @override
  Future<CheckAutofillResponse> checkAutofill(
    CheckAutofillRequest request,
  ) async {
    if (Platform.isAndroid) {
      _logger.fine('_checkAutofillRequest');
      return CheckAutofillResponse(
          _autofillHintsProvider.autofillHints != null);
    } else {
      return CheckAutofillResponse(false);
    }
  }

  @override
  Future<void> deleteCurrentServerData() async {
    if (Platform.isIOS) {
      await Autofill.removeAllCredentials();
    }

    return await _secureStorageProvider.deleteAll();
  }

  @override
  Future<String> getUserName() {
    return _secureStorageProvider.getProperty(SecureStorageKey.USER_NAME);
  }

  @override
  Future<bool> isLoginWithBiometricsEnabled() {
    return _settingsProvider.getProperty(SettingsKey.loginWithBiometrics);
  }

  @override
  Future<void> login(LoginRequest loginRequest) async {
    final fingerprint = await _secureStorageProvider
        .getProperty(SecureStorageKey.PUBLIC_KEY_FINGERPRINT);

    final sendFingerprintResponse =
        await _loginApi.sendFingerprint(SendFingerprintRequest(fingerprint));

    final encryptedNonce = sendFingerprintResponse.encryptedNonce;

    final privateKey = await _secureStorageProvider
        .getProperty(SecureStorageKey.TEMP_PRIVATE_KEY_ASC);

    final decryptedNonce = await decryptOpenPgpJsMessage(
        encryptedNonce, privateKey, loginRequest.passphrase);

    if (decryptedNonce == null) {
      throw AppException('Invalid private key or passphrase.');
    }

    _logger.fine(decryptedNonce);

    final userResponse = await _loginApi.sendDecryptedNonce(
      SendDecryptedNonceRequest(
        decryptedNonce,
        fingerprint,
      ),
    );

    _passphraseProvider.passphrase = loginRequest.passphrase;

    if ((await _secureStorageProvider.getProperty(
          SecureStorageKey.PRIVATE_KEY_ASC,
        )) ==
        null) {
      unawaited(
        _firebaseAnalytics.logEvent(name: AnalyticsEvents.eventLoginComplete),
      );
    }

    await _secureStorageProvider.setProperty(
        SecureStorageKey.USER_NAME, userResponse.userName);

    await _secureStorageProvider.setProperty(
        SecureStorageKey.PRIVATE_KEY_ASC, privateKey);

    final isLoginWithBiometrics =
        await _settingsProvider.getProperty(SettingsKey.loginWithBiometrics);
  }

  @override
  Future<void> loginWithBiometrics() async {
    final errorMessage =
        'Invalid biometrics state. Please, input your passphrase manually.';

    final aliasForPassphraseKey = await _secureStorageProvider.getProperty(
      SecureStorageKey.ALIAS_FOR_PASSPHRASE_KEY,
    );

    if (aliasForPassphraseKey == null) {
      _logger.warning('aliasForPassphraseKey == null');
      throw AppException(errorMessage);
    }

    String passphrase;

    try {
      passphrase = await BiometricsVault.getSecretWithBiometrics(
        instructions: 'Unlock with biometrics.',
        key: aliasForPassphraseKey,
        accessGroupId: AppAssembly.accessGroupId,
      );

      if (passphrase == null) {
        // iOS returns null
        throw AppException(errorMessage);
      }
    } catch (error) {
      // Android throws error
      if (error is PlatformException) {
        _logger.warning(
          'error code: ${error.code} message: ${error.message} details: ${error.details}',
        );

        if (error.code == BiometricsVaultErrorCode.unrecoverableKey ||
            error.code == BiometricsVaultErrorCode.keyPermanentlyInvalidated) {
          await _removeBiometricsData();
        } else if (error.code == BiometricsVaultErrorCode.canceled) {
          throw AppException(error.code);
        }
      }

      throw AppException(errorMessage);
    }

    await login(LoginRequest(passphrase));
  }

  Future<void> _removeBiometricsData() async {
    await _secureStorageProvider
        .deleteProperty(SecureStorageKey.ALIAS_FOR_PASSPHRASE_KEY);
    await _settingsProvider.setProperty(SettingsKey.loginWithBiometrics, false);
  }
}
