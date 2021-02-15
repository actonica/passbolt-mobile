// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/api/permissions_api.dart';
import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';
import 'package:passbolt_flutter/data/providers/groups_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';

abstract class BasePermissionsProvider {
  Future<List<AroPermission>> getPermissions(GetPermissionsRequest request);
}

class PermissionsProvider implements BasePermissionsProvider {
  final BasePermissionsApi _permissionsApi;
  final BaseUsersProvider _usersProvider;
  final BaseGroupsProvider _groupsProvider;

  PermissionsProvider(
    this._permissionsApi,
    this._usersProvider,
    this._groupsProvider,
  );

  @override
  Future<List<AroPermission>> getPermissions(
      GetPermissionsRequest request) async {
    final response = await _permissionsApi.getPermissions(request);

    List<AroPermission> result = [];

    await Future.forEach(
      response.permissions,
      (Permission permission) async {
        switch (permission.aroType) {
          case AroType.group:
            final group = await _groupsProvider.getGroup(permission.aroId);
            result.add(
              AroPermission(
                permission,
                Aro(
                  avatarUrl: group.avatarUrl,
                  name: group.name,
                  info: 'Group',
                  userOrGroupId: group.id,
                ),
              ),
            );
            break;
          case AroType.user:
            final user = await _usersProvider.getUser(permission.aroId);
            result.add(
              AroPermission(
                permission,
                Aro(
                    avatarUrl: user.profile.avatarUrl,
                    name: '${user.profile.firstName} ${user.profile.lastName}',
                    info: user.name,
                    userOrGroupId: user.id),
              ),
            );
            break;
        }
      },
    );

    return result;
  }
}
