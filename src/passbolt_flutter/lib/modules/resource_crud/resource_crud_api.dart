// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_resource.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class CreateResourceRequest {
  final String name;
  final String uri;
  final String userName;
  final String userId;
  final String encryptedPassword;
  final String description;

  CreateResourceRequest({
    @required this.userId,
    @required this.name,
    this.uri,
    this.userName,
    @required this.encryptedPassword,
    this.description,
  });
}

class CreateResourceResponse {
  final Resource resource;

  CreateResourceResponse(this.resource);
}

class DeleteResourceRequest {
  final String resourceId;

  DeleteResourceRequest(this.resourceId);
}

class DeleteResourceResponse {}

class UpdateResourceRequest {
  final String resourceId;
  final String name;
  final String uri;
  final String userName;
  final List<Map<String, String>> secrets;
  final String description;

  UpdateResourceRequest({
    @required this.resourceId,
    @required this.name,
    this.uri,
    this.userName,
    @required this.secrets,
    this.description,
  });
}

class UpdateResourceResponse {
  final Resource resource;

  UpdateResourceResponse(this.resource);
}

abstract class BaseResourceCrudApi {
  Future<CreateResourceResponse> createResource(CreateResourceRequest request);

  Future<DeleteResourceResponse> deleteResource(DeleteResourceRequest request);

  Future<UpdateResourceResponse> updateResource(UpdateResourceRequest request);
}

class ResourceCrudApi extends ServerApi implements BaseResourceCrudApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;

  ResourceCrudApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<CreateResourceResponse> createResource(CreateResourceRequest request) {
    return execute(
      () async {
        final url =
            '${await _secureStorageProvider.getProperty(SecureStorageKey.BASE_URL)}/resources.json?api-version=v2';
        logger.fine('http request url: $url');

        final client = _prepareClient();

        final data = Map<String, dynamic>();
        data['name'] = request.name;
        data['uri'] = request.uri;
        data['username'] = request.userName;
        data['description'] = request.description;
        data['secrets'] = [
          {'data': request.encryptedPassword}
        ];

        final wsResponse = await client.post(url, data: data);
        printResponse(wsResponse);

        final wsResource = PassboltResource.fromJson(wsResponse.data['body']);
        final resource = Resource.from(wsResource);
        logger.fine('resource id $resource');

        return CreateResourceResponse(resource);
      },
    );
  }

  @override
  Future<DeleteResourceResponse> deleteResource(DeleteResourceRequest request) {
    return execute(
      () async {
        final url =
            '${await _secureStorageProvider.getProperty(SecureStorageKey.BASE_URL)}/resources/${request.resourceId}.json?api-version=v2';
        logger.fine('http request url: $url');

        final client = _prepareClient();

        final wsResponse = await client.delete(url);
        printResponse(wsResponse);

        return DeleteResourceResponse();
      },
    );
  }

  @override
  Future<UpdateResourceResponse> updateResource(UpdateResourceRequest request) {
    return execute(
      () async {
        final url =
            '${await _secureStorageProvider.getProperty(SecureStorageKey.BASE_URL)}/resources/${request.resourceId}.json?api-version=v2';
        logger.fine('http request url: $url');

        final data = Map<String, dynamic>();
        data['name'] = request.name;
        data['uri'] = request.uri;
        data['username'] = request.userName;
        data['description'] = request.description;
        data['secrets'] = request.secrets;

        final client = _prepareClient();

        final wsResponse = await client.put(url, data: data);
        printResponse(wsResponse);

        final wsResource = PassboltResource.fromJson(wsResponse.data['body']);
        final resource = Resource.from(wsResource);
        logger.fine('resource id $resource');

        return UpdateResourceResponse(resource);
      },
    );
  }

  Dio _prepareClient() {
    final client = _httpClientProvider.getHttpClient();
    client.options.headers['X-CSRF-Token'] =
        '${_cookiesProvider.csrf.split('=')[1]}';
    client.options.headers['Cookie'] =
        '${_cookiesProvider.cakePhp}; ${_cookiesProvider.csrf}';
    client.options.headers['Content-Type'] = 'application/json';
    return client;
  }
}
