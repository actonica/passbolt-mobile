// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_user.dart';
import 'package:passbolt_flutter/data/entities/user.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class GetUsersResponse {
  final List<User> users;

  GetUsersResponse(this.users);
}

class GetUserRequest {
  final String userId;

  GetUserRequest(this.userId);
}

class GetUserResponse {
  final User user;

  GetUserResponse(this.user);
}

abstract class BaseUsersApi {
  Future<GetUsersResponse> getUsers();

  Future<GetUsersResponse> getUsersWithAccess(String resourceId);

  Future<GetUserResponse> getUser(GetUserRequest request);
}

class UsersApi extends ServerApi implements BaseUsersApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("UsersApi");

  UsersApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetUsersResponse> getUsers() {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url = '$baseUrl/users.json?api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponse(wsResponse);

        final List<dynamic> json = wsResponse.data['body'];
        final passboltUsers = json.map(
          (value) {
            return PassboltUser.fromJson(value as Map<String, dynamic>);
          },
        ).toList();

        passboltUsers.removeWhere(
          (passboltUser) {
            return passboltUser.gpgkey == null;
          },
        );

        final users = passboltUsers.map(
          (PassboltUser passboltUser) {
            return User.from(passboltUser, baseUrl);
          },
        ).toList();

        return GetUsersResponse(users);
      },
    );
  }

  @override
  Future<GetUsersResponse> getUsersWithAccess(String resourceId) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url =
            '$baseUrl/users.json?filter[has-access]=${resourceId}&api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponseWithoutBody(wsResponse);

        final List<dynamic> json = wsResponse.data['body'];
        final passboltUsers = json.map((value) {
          return PassboltUser.fromJson(value as Map<String, dynamic>);
        }).toList();

        final users = passboltUsers.map((PassboltUser passboltUser) {
          return User.from(passboltUser, baseUrl);
        }).toList();

        return GetUsersResponse(users);
      },
    );
  }

  @override
  Future<GetUserResponse> getUser(GetUserRequest request) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url = '$baseUrl/users/${request.userId}.json?api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponse(wsResponse);

        final passboltUser = PassboltUser.fromJson(wsResponse.data['body']);

        final user = User.from(passboltUser, baseUrl);

        _logger.fine('users $user');

        return GetUserResponse(user);
      },
    );
  }
}
