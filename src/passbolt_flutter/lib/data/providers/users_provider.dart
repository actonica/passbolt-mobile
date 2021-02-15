// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/api/users_api.dart';
import 'package:passbolt_flutter/data/entities/user.dart';

abstract class BaseUsersProvider {
  User getCurrentUser();

  void setCurrentUser(User user);

  Future<User> getUser(String id);

  Future<List<User>> getUsersWithAccess(String resourceId);
}

class UsersProvider implements BaseUsersProvider {
  final BaseUsersApi _usersApi;
  List<User> _users = [];
  User _currentUser;

  UsersProvider(this._usersApi);

  @override
  User getCurrentUser() {
    return _currentUser;
  }

  @override
  void setCurrentUser(User user) {
    _currentUser = user;
  }

  @override
  Future<User> getUser(String id) async {
    User result;
    try {
      result = _users.firstWhere(
        (user) {
          return user.id == id;
        },
      );
    } catch (_) {
      final response = await _usersApi.getUser(GetUserRequest(id));
      result = response.user;
    }
    return result;
  }

  @override
  Future<List<User>> getUsersWithAccess(String resourceId) async {
    _users = [];
    final wsResponse = await _usersApi.getUsersWithAccess(resourceId);
    _users = wsResponse.users;
    return _users;
  }
}
