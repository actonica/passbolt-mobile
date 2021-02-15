// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_public_key.dart';
import 'package:passbolt_flutter/data/entities/public_key.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class GetGpgKeysRequest {}

class GetGpgKeysResponse {
  final List<PublicKey> gpgKeys;

  GetGpgKeysResponse(this.gpgKeys);
}

abstract class BaseGpgKeysApi {
  Future<GetGpgKeysResponse> getGpgKeys(GetGpgKeysRequest request);
}

class GpgKeysApi extends ServerApi implements BaseGpgKeysApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("GpgKeysApi");

  GpgKeysApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetGpgKeysResponse> getGpgKeys(GetGpgKeysRequest request) {
    return execute(
      () async {
        final url = '${await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        )}/gpgkeys.json?api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponseWithoutBody(wsResponse);

        final List<dynamic> json = wsResponse.data['body'];
        final passboltKeys = json.map((value) {
          return PassboltPublicKey.fromJson(value as Map<String, dynamic>);
        }).toList();

        final keys = passboltKeys.map((PassboltPublicKey passboltKey) {
          return PublicKey.from(passboltKey);
        }).toList();

        return GetGpgKeysResponse(keys);
      },
    );
  }
}
