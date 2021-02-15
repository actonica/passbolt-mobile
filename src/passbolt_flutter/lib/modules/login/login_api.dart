// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_user.dart';
import 'package:passbolt_flutter/data/entities/user.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';

class SendFingerprintRequest {
  final String fingerprint;

  SendFingerprintRequest(this.fingerprint);
}

class SendFingerprintResponse {
  final String encryptedNonce;

  SendFingerprintResponse(this.encryptedNonce);
}

class SendDecryptedNonceRequest {
  final String decryptedNonce;
  final String fingerprint;

  SendDecryptedNonceRequest(this.decryptedNonce, this.fingerprint);
}

class SendDecryptedNonceResponse {
  final String userName;

  SendDecryptedNonceResponse(this.userName);
}

abstract class BaseLoginApi {
  Future<SendFingerprintResponse> sendFingerprint(
      SendFingerprintRequest request);

  Future<SendDecryptedNonceResponse> sendDecryptedNonce(
      SendDecryptedNonceRequest request);
}

class LoginApi extends ServerApi implements BaseLoginApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final BaseUsersProvider _usersProvider;
  final _logger = Logger('LoginApi');

  LoginApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    this._usersProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<SendFingerprintResponse> sendFingerprint(
      SendFingerprintRequest request) async {
    return execute(
      () async {
        final String url =
            '${await _secureStorageProvider.getProperty(SecureStorageKey.BASE_URL)}/auth/login.json?api-version=v2';
        _logger.fine('http request url: $url');

        final String bodyEncoded =
            Uri.encodeFull('data[gpg_auth][keyid]=${request.fingerprint}');
        _logger.fine('http request body: $bodyEncoded');

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['content-type'] =
            'application/x-www-form-urlencoded';

        final wsResponse = await client.post(url, data: bodyEncoded);

        _logger.fine('http response headers: ${wsResponse.headers}');
        _logger.fine('http response data: ${wsResponse.data}');

        final encodedAndEncryptedNonce =
            wsResponse.headers.value('x-gpgauth-user-auth-token');
        final encryptedNonce = Uri.decodeComponent(encodedAndEncryptedNonce);

        _logger.fine('encrypted nonce: $encryptedNonce');

        return SendFingerprintResponse(encryptedNonce);
      },
    );
  }

  @override
  Future<SendDecryptedNonceResponse> sendDecryptedNonce(
      SendDecryptedNonceRequest request) async {
    return execute(
      () async {
        final String baseUrl =
            await _secureStorageProvider.getProperty(SecureStorageKey.BASE_URL);
        final String url = '$baseUrl/auth/login.json?api-version=v2';
        _logger.fine('http request url: $url');

        final String bodyEncoded = Uri.encodeFull(
                'data[gpg_auth][keyid]=${request.fingerprint}&data[gpg_auth][user_token_result]=') +
            request.decryptedNonce;
        _logger.fine('http request body: $bodyEncoded');

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['content-type'] =
            'application/x-www-form-urlencoded';

        final wsResponse = await client.post(url, data: bodyEncoded);

        _logger.fine('http response headers: ${wsResponse.headers}');
        _logger.fine('http response data: ${wsResponse.data}');

        final wsUser = PassboltUser.fromJson(wsResponse.data['body']);
        final user = User.from(wsUser, baseUrl);
        _usersProvider.setCurrentUser(user);
        _logger.fine('user ${_usersProvider.getCurrentUser()}');

        final cakePhpCookie =
            wsResponse.headers.value('set-cookie').split(';')[0];
        _cookiesProvider.cakePhp = cakePhpCookie;
        return SendDecryptedNonceResponse(_usersProvider.getCurrentUser().name);
      },
    );
  }
}
