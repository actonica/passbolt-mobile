// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:openpgp/openpgp.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/api/permissions_api.dart';
import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';
import 'package:passbolt_flutter/data/entities/public_key.dart';
import 'package:passbolt_flutter/data/providers/groups_provider.dart';
import 'package:passbolt_flutter/data/providers/permissions_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';

abstract class BaseSharingInteractor implements Interactor {
  Future<List<AroPermission>> getPermissions(GetPermissionsRequest request);

  Future<SearchArosResponse> searchAros(SearchArosRequest request);

  Future<ShareResponse> share(
    String resourceId,
    String password,
    List<AroPermission> newArosPermissions,
    List<AroPermission> deletedArosPermissions,
  );
}

class SharingInteractor implements BaseSharingInteractor {
  final BaseSharingApi _sharingApi;
  final BaseUsersProvider _usersProvider;
  final BaseGroupsProvider _groupsProvider;
  final BasePermissionsProvider _permissionsProvider;
  final _logger = Logger("SharingInteractor");

  SharingInteractor(
    this._sharingApi,
    this._permissionsProvider,
    this._usersProvider,
    this._groupsProvider,
  );

  @override
  Future<List<AroPermission>> getPermissions(
      GetPermissionsRequest request) async {
    return _permissionsProvider.getPermissions(request);
  }

  @override
  Future<SearchArosResponse> searchAros(SearchArosRequest request) async {
    return _sharingApi.searchAros(request);
  }

  @override
  Future<ShareResponse> share(
    String resourceId,
    String password,
    List<AroPermission> newArosPermissions,
    List<AroPermission> deletedArosPermissions,
  ) async {
    final List<Map<String, dynamic>> permissions = [];
    final List<Map<String, dynamic>> secrets = [];

    await Future.forEach(
      newArosPermissions,
      (AroPermission element) async {
        permissions.add(_buildNewPermissionChange(resourceId, element));
      },
    );

    await Future.forEach(
      deletedArosPermissions,
      (AroPermission element) async {
        permissions.add(_buildDeletePermissionChange(resourceId, element));
      },
    );

    final simulateSharingResponse = await _sharingApi.simulateSharing(
      SimulateSharingRequest(resourceId, permissions),
    );

    final List<String> userIds = simulateSharingResponse.added;

    // for each user id encrypt password with their public key
    final publicKeysMap = Map<String, PublicKey>();
    for (final userId in userIds) {
      publicKeysMap[userId] = (await _usersProvider.getUser(userId)).publicKey;
    }

    await Future.forEach(
      userIds,
      (userId) async {
        final key = publicKeysMap[userId];

        final encryptedPasswordWithKey =
            await OpenPGP.encrypt(password, key.armoredKey);

        secrets.add(
          {
            'user_id': userId,
            'data': encryptedPasswordWithKey,
          },
        );
      },
    );

    return _sharingApi.share(ShareRequest(resourceId, permissions, secrets));
  }

  Map<String, dynamic> _buildNewPermissionChange(
    String resourceId,
    AroPermission aroPermission,
  ) {
    return {
      'id': aroPermission.permission.id,
      'is_new': aroPermission.permission.id != null ? false : true,
      'aro':
          aroPermission.permission.aroType == AroType.user ? 'User' : 'Group',
      'aro_foreign_key': aroPermission.permission.aroId,
      'aco': 'Resource',
      'aco_foreign_key': resourceId,
      'type': aroPermission.permission.type.intFromType,
    };
  }

  Map<String, dynamic> _buildDeletePermissionChange(
    String resourceId,
    AroPermission aroPermission,
  ) {
    return {
      'id': aroPermission.permission.id,
      'aro':
          aroPermission.permission.aroType == AroType.user ? 'User' : 'Group',
      'aro_foreign_key': aroPermission.permission.aroId,
      'aco': 'Resource',
      'aco_foreign_key': resourceId,
      'type': aroPermission.permission.type.intFromType,
      'delete': true
    };
  }
}
