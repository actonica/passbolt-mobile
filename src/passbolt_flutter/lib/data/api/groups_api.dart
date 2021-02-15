// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/group.dart';
import 'package:passbolt_flutter/data/entities/passbolt_group.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class GetGroupRequest {
  final String groupId;

  GetGroupRequest(this.groupId);
}

class GetGroupResponse {
  final Group group;

  GetGroupResponse(this.group);
}

class GetGroupsResponse {
  final List<Group> groups;

  GetGroupsResponse(this.groups);
}

abstract class BaseGroupsApi {
  Future<GetGroupResponse> getGroup(GetGroupRequest request);

  Future<GetGroupsResponse> getGroups();
}

class GroupsApi extends ServerApi implements BaseGroupsApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("GroupsApi");

  GroupsApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetGroupResponse> getGroup(GetGroupRequest request) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url = '$baseUrl/groups/${request.groupId}.json?api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponseWithoutBody(wsResponse);

        final passboltGroup = PassboltGroup.fromJson(wsResponse.data['body']);

        return GetGroupResponse(Group.from(passboltGroup, baseUrl));
      },
    );
  }

  @override
  Future<GetGroupsResponse> getGroups() {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url = '$baseUrl/groups.json?api-version=v2&contain[user]=1';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponseWithoutBody(wsResponse);

        final List<dynamic> json = wsResponse.data['body'];

        final groups = json.map((item) {
          final groupJson = item as Map<String, dynamic>;
          final passboltGroup = PassboltGroup.fromJson(groupJson);
          return Group.from(passboltGroup, baseUrl);
        }).toList();

        return GetGroupsResponse(groups);
      },
    );
  }
}
