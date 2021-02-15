// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_permission.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class GetPermissionsRequest {
  final String resourceId;

  GetPermissionsRequest(this.resourceId);
}

class GetPermissionsResponse {
  final List<Permission> permissions;

  GetPermissionsResponse(this.permissions);
}

abstract class BasePermissionsApi {
  Future<GetPermissionsResponse> getPermissions(GetPermissionsRequest request);
}

class PermissionsApi extends ServerApi implements BasePermissionsApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("PermissionsApi");

  PermissionsApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetPermissionsResponse> getPermissions(GetPermissionsRequest request) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url =
            '$baseUrl/permissions/resource/${request.resourceId}.json?api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponseWithoutBody(wsResponse);

        final List<dynamic> json = wsResponse.data['body'];
        final passboltPermissions = json.map((value) {
          return PassboltPermission.fromJson(value as Map<String, dynamic>);
        }).toList();

        final permissions =
            passboltPermissions.map((PassboltPermission passboltPermission) {
          return Permission.from(passboltPermission);
        }).toList();

        _logger.fine('permissions $permissions');

        return GetPermissionsResponse(permissions);
      },
    );
  }
}
