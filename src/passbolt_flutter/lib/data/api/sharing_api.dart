// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_entities.dart';

class Aro implements AroItem {
  final String avatarUrl;
  final String name;
  final String info;
  final String userOrGroupId;

  Aro({
    this.avatarUrl,
    @required this.name,
    @required this.info,
    @required this.userOrGroupId,
  });
}

class SearchArosRequest {
  final String input;

  SearchArosRequest(this.input);
}

class SearchArosResponse {
  final List<Aro> aroEntries;

  SearchArosResponse(this.aroEntries);
}

class ShareRequest {
  final String resourceId;
  final List<Map<String, dynamic>> permissions;
  final List<Map<String, dynamic>> secrets;

  ShareRequest(this.resourceId, this.permissions, this.secrets);
}

class ShareResponse {}

class SimulateSharingRequest {
  final String resourceId;
  final List<Map<String, dynamic>> permissions;

  SimulateSharingRequest(this.resourceId, this.permissions);
}

class SimulateSharingResponse {
  final List<String> added;

  SimulateSharingResponse(this.added);
}

abstract class BaseSharingApi {
  Future<SearchArosResponse> searchAros(SearchArosRequest request);

  Future<ShareResponse> share(ShareRequest request);

  Future<SimulateSharingResponse> simulateSharing(
    SimulateSharingRequest request,
  );
}

class SharingApi extends ServerApi implements BaseSharingApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("SharingApi");

  SharingApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<SearchArosResponse> searchAros(SearchArosRequest request) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url =
            '$baseUrl/share/search-aros.json?filter[search]=${request.input}&api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponseWithoutBody(wsResponse);

        final List<dynamic> json = wsResponse.data['body'];

        final List<Aro> arosEntry = json.map(
          (item) {
            final aroJson = item as Map<String, dynamic>;
            // User
            if (aroJson['username'] != null) {
              return Aro(
                avatarUrl: '$baseUrl/${aroJson['profile']['avatar']['url']['medium']}',
                name:
                    '${aroJson['profile']['first_name']} ${aroJson['profile']['last_name']}',
                info: aroJson['username'],
                userOrGroupId: aroJson['id'],
              );
            }
            // Group
            else {
              return Aro(
                avatarUrl: null,
                name: aroJson['name'],
                info: 'Group',
                userOrGroupId: aroJson['id'],
              );
            }
          },
        ).toList();

        return SearchArosResponse(arosEntry);
      },
    );
  }

  @override
  Future<SimulateSharingResponse> simulateSharing(
      SimulateSharingRequest request) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['X-CSRF-Token'] =
            '${_cookiesProvider.csrf.split('=')[1]}';
        client.options.headers['Cookie'] =
            '${_cookiesProvider.cakePhp}; ${_cookiesProvider.csrf}';
        client.options.headers['Content-Type'] = 'application/json';

        final data = Map<String, dynamic>();
        data['permissions'] = request.permissions;

        _logger.fine('data $data');

        final urlSimulatingSharing =
            '$baseUrl/share/simulate/resource/${request.resourceId}.json?api-version=v2';

        var wsResponse = await client.post(urlSimulatingSharing, data: data);
        printResponse(wsResponse);

        final added =
            (wsResponse.data['body']['changes']['added'] as List<dynamic>)
                .map((value) {
          return value['User']['id'].toString();
        }).toList();

        return SimulateSharingResponse(added);
      },
    );
  }

  @override
  Future<ShareResponse> share(ShareRequest request) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['X-CSRF-Token'] =
            '${_cookiesProvider.csrf.split('=')[1]}';
        client.options.headers['Cookie'] =
            '${_cookiesProvider.cakePhp}; ${_cookiesProvider.csrf}';
        client.options.headers['Content-Type'] = 'application/json';

        final data = Map<String, dynamic>();
        data['permissions'] = request.permissions;
        data['secrets'] = request.secrets;

        _logger.fine('data $data');

        // sharing
        final urlSharing =
            '$baseUrl/share/resource/${request.resourceId}.json?api-version=v2';

        final wsResponse = await client.put(urlSharing, data: data);
        printResponse(wsResponse);

        return ShareResponse();
      },
    );
  }
}
