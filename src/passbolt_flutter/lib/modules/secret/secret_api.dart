// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_secret.dart';
import 'package:passbolt_flutter/data/entities/secret.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class GetSecretRequest {
  final String resourceId;

  GetSecretRequest(this.resourceId);
}

class GetSecretResponse {
  final Secret secret;

  GetSecretResponse(this.secret);
}

abstract class BaseSecretApi {
  Future<GetSecretResponse> getSecret(GetSecretRequest request);
}

class SecretApi extends ServerApi implements BaseSecretApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("SecretApi");

  SecretApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetSecretResponse> getSecret(GetSecretRequest request) async {
    return execute(
      () async {
        final url =
            '${await _secureStorageProvider.getProperty(SecureStorageKey.BASE_URL)}/secrets/resource/${request.resourceId}.json?api-version=v2';
        _logger.fine('http request url: $url');

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        _logger.fine('http response headers ${wsResponse.headers}');
        _logger.fine('http response statusCode ${wsResponse.statusCode}');
        _logger.fine('http response statusMessage ${wsResponse.statusMessage}');
        _logger.fine('http response ${wsResponse.data}');

        final Map<String, dynamic> json = wsResponse.data["body"];

        final PassboltSecret passboltSecret = PassboltSecret.fromJson(json);

        final Secret secret = Secret(passboltSecret.data);

        _logger.fine("secret $secret");

        return GetSecretResponse(secret);
      },
    );
  }
}
