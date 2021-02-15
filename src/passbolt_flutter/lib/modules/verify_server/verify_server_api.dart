// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';

class GetServerPublicKeyRequest {
  final String passboltServerUrl;

  GetServerPublicKeyRequest(this.passboltServerUrl);
}

class GetServerPublicKeyResponse {
  final String serverPublicKey;

  GetServerPublicKeyResponse(this.serverPublicKey);
}

class CheckPassboltServerUserData {
  final String passboltServerUrl;
  final String clientPublicKeyFingerprint;

  CheckPassboltServerUserData(
    this.passboltServerUrl,
    this.clientPublicKeyFingerprint,
  );
}

class CheckPassboltServerRequest {
  final CheckPassboltServerUserData userData;
  final String clearNonce;
  final String encodedNonce;

  CheckPassboltServerRequest(
    this.userData,
    this.clearNonce,
    this.encodedNonce,
  );
}

class CheckPassboltServerResponse {}

abstract class BaseVerifyServerApi {
  Future<GetServerPublicKeyResponse> getServerPublicKey(
    GetServerPublicKeyRequest request,
  );

  Future<CheckPassboltServerResponse> checkPassboltServer(
    CheckPassboltServerRequest request,
  );
}

class VerifyServerApi extends ServerApi implements BaseVerifyServerApi {
  final BaseHttpClientProvider _httpClientProvider;
  final _logger = Logger('VerifyServerApi');

  VerifyServerApi(
    this._httpClientProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetServerPublicKeyResponse> getServerPublicKey(
    GetServerPublicKeyRequest request,
  ) async {
    return execute(
      () async {
        final url =
            '${request.passboltServerUrl}/auth/verify.json?api-version=v2';
        _logger.fine('http request url: $url');
        final client = _httpClientProvider.getHttpClient();
        final wsResponse = await client.get(url);

        _logger.fine('http response ${wsResponse.data}');

        final keyData = wsResponse.data['body']['keydata'];
        _logger.fine('keyData $keyData');

        return GetServerPublicKeyResponse(keyData);
      },
    );
  }

  @override
  Future<CheckPassboltServerResponse> checkPassboltServer(
    CheckPassboltServerRequest request,
  ) async {
    return execute(
      () async {
        final url =
            '${request.userData.passboltServerUrl}/auth/verify.json?api-version=v2';
        _logger.fine('http request url: $url');

        final bodyEncoded = Uri.encodeFull(
                'data[gpg_auth][keyid]=${request.userData.clientPublicKeyFingerprint}&data[gpg_auth][server_verify_token]=') +
            Uri.encodeComponent(request.encodedNonce);
        _logger.fine('http request body: $bodyEncoded');

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['content-type'] =
            'application/x-www-form-urlencoded';

        final wsResponse = await client.post(url, data: bodyEncoded);

        _logger.fine('http response headers: ${wsResponse.headers}');
        _logger.fine('http response data: ${wsResponse.data}');

        final serverNonce =
            wsResponse.headers.value('x-gpgauth-verify-response');

        _logger.fine('serverNonce = $serverNonce');

        if (request.clearNonce != serverNonce) {
          throw AppException(
            'Error. Check passbolt server url or your public key fingerprint.',
          );
        }

        return CheckPassboltServerResponse();
      },
    );
  }
}
