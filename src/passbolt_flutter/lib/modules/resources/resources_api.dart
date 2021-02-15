// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_resource.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class GetResourcesRequest {}

class GetResourcesResponse {
  final List<Resource> resources;

  GetResourcesResponse(this.resources);
}

abstract class BaseResourcesApi {
  Future<GetResourcesResponse> getResources(GetResourcesRequest request);
}

class ResourcesApi extends ServerApi implements BaseResourcesApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("ResourcesApi");

  ResourcesApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetResourcesResponse> getResources(GetResourcesRequest request) async {
    return execute(
      () async {
        final url =
            "${await _secureStorageProvider.getProperty(SecureStorageKey.BASE_URL)}/resources.json?api-version=v2&contain[permission]=1";

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponseWithoutBody(wsResponse);

        final List<dynamic> json = wsResponse.data["body"];

        final passboltResources = json.map(
          (value) {
            return PassboltResource.fromJson(value as Map<String, dynamic>);
          },
        ).toList();

        final resources =
            passboltResources.map((PassboltResource passboltResource) {
          return Resource.from(passboltResource);
        }).toList();

        final csrfToken = wsResponse.headers.value('set-cookie').split(';')[0];
        _cookiesProvider.csrf = csrfToken;

        return GetResourcesResponse(resources);
      },
    );
  }
}
