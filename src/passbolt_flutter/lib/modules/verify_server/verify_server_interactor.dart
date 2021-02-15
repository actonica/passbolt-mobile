// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:openpgp/openpgp.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_api.dart';
import 'package:uuid/uuid.dart';

abstract class BaseVerifyServerInteractor implements Interactor {
  Future<CheckPassboltServerResponse> checkPassboltServer(
      CheckPassboltServerUserData userData);
}

class VerifyServerInteractor implements BaseVerifyServerInteractor {
  final BaseVerifyServerApi _api;
  final BaseSecureStorageProvider _secureStorageProvider;
  final _logger = Logger("VerifyServerInteractor");

  VerifyServerInteractor(
    this._api,
    this._secureStorageProvider,
  );

  @override
  Future<CheckPassboltServerResponse> checkPassboltServer(
    CheckPassboltServerUserData userData,
  ) async {
    try {
      final publicKeyResponse = await _api.getServerPublicKey(
        GetServerPublicKeyRequest(
          userData.passboltServerUrl,
        ),
      );

      final clearNonce = "gpgauthv1.3.0|36|${Uuid().v4()}|gpgauthv1.3.0";

      _logger.fine("clearNonce $clearNonce");

      final encodedNonce = await OpenPGP.encrypt(
          clearNonce, publicKeyResponse.serverPublicKey);

      _logger.fine("encodedNonce = $encodedNonce");

      final checkResponse = await _api.checkPassboltServer(
        CheckPassboltServerRequest(
          userData,
          clearNonce,
          encodedNonce,
        ),
      );

      await _secureStorageProvider.setProperty(
        SecureStorageKey.BASE_URL,
        userData.passboltServerUrl,
      );

      await _secureStorageProvider.setProperty(
        SecureStorageKey.PUBLIC_KEY_FINGERPRINT,
        userData.clientPublicKeyFingerprint,
      );

      return checkResponse;
    } catch (error) {
      if (error is NoInternetException) {
        rethrow;
      } else {
        throw AppException(
          'Error. Check passbolt server url or your public key fingerprint.',
        );
      }
    }
  }
}
