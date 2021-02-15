// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:io';

import 'package:autofill/autofill.dart';
import 'package:logging/logging.dart';
import 'package:openpgp/openpgp.dart';

import '../../common/interactor.dart';
import '../../data/api/permissions_api.dart';
import '../../data/entities/permission.dart';
import '../../data/entities/public_key.dart';
import '../../data/entities/resource.dart';
import '../../data/providers/groups_provider.dart';
import '../../data/providers/users_provider.dart';
import 'resource_crud_api.dart';
import 'resource_crud_entities.dart';

abstract class BaseResourceCrudInteractor implements Interactor {
  Future<CreateResourceResponse> createResource(CreateResourceIntent action);

  Future<UpdateResourceResponse> updateResource(
      Resource oldResource, UpdateResourceIntent action);
}

class ResourceCrudInteractor implements BaseResourceCrudInteractor {
  final BaseResourceCrudApi _resourceCrudApi;
  final BasePermissionsApi _permissionsApi;
  final BaseGroupsProvider _groupsProvider;
  final BaseUsersProvider _usersProvider;
  final _logger = Logger("ResourceCrudInteractor");

  ResourceCrudInteractor(
    this._resourceCrudApi,
    this._permissionsApi,
    this._groupsProvider,
    this._usersProvider,
  );

  @override
  Future<CreateResourceResponse> createResource(
      CreateResourceIntent action) async {
    final user = _usersProvider.getCurrentUser();
    final encryptedPassword = await OpenPGP.encrypt(
      action.password,
      user.publicKey.armoredKey,
    );
    final request = CreateResourceRequest(
      userId: user.id,
      name: action.name,
      uri: action.uri,
      userName: action.userName,
      encryptedPassword: encryptedPassword,
      description: action.description,
    );
    final response = await _resourceCrudApi.createResource(request);

    if (Platform.isIOS) {
      if (response.resource.uri != null &&
          response.resource.uri.isNotEmpty &&
          response.resource.username != null &&
          response.resource.username.isNotEmpty) {
        final newCredentials = AutofillCredential(response.resource.uri,
            response.resource.username, response.resource.id);
        await Autofill.addCredentials([newCredentials]);
      }
    }

    return response;
  }

  @override
  Future<UpdateResourceResponse> updateResource(
    Resource oldResource,
    UpdateResourceIntent action,
  ) async {
    // get resource permissions
    final permissions = (await _permissionsApi
            .getPermissions(GetPermissionsRequest(action.resourceId)))
        .permissions;

    // collect user ids from permissions
    Set<String> userIds = {};
    await Future.forEach(
      permissions,
      (Permission permission) async {
        // https://help.passbolt.com/api/permissions
        if (permission.aroType == AroType.user) {
          userIds.add(permission.aroId);
        } else if (permission.aroType == AroType.group) {
          final group = await _groupsProvider.getGroup(
            permission.aroId,
          );
          group.users.forEach(
            (userId) {
              userIds.add(userId);
            },
          );
        }
      },
    );

    // for each user id encrypt password with their public key
    final publicKeys = Map<String, PublicKey>();

    for (final userId in userIds) {
      final user = await _usersProvider.getUser(userId);
      publicKeys[userId] = user.publicKey;
    }

    final List<Map<String, String>> secrets = [];

    await Future.forEach(
      userIds,
      (userId) async {
        final key = publicKeys[userId];

        final encryptedPasswordWithKey =
            await OpenPGP.encrypt(action.password, key.armoredKey);

        secrets.add({'user_id': userId, 'data': encryptedPasswordWithKey});
      },
    );

    final request = UpdateResourceRequest(
      resourceId: action.resourceId,
      name: action.name,
      uri: action.uri,
      userName: action.userName,
      description: action.description,
      secrets: secrets,
    );

    final response = await _resourceCrudApi.updateResource(request);

    if (Platform.isIOS) {
      if (oldResource.uri != null &&
          oldResource.uri.isNotEmpty &&
          oldResource.username != null &&
          oldResource.username.isNotEmpty) {
        final oldCredentials = AutofillCredential(
          oldResource.uri,
          oldResource.username,
          oldResource.id,
        );
        await Autofill.removeCredentials([oldCredentials]);
      }

      if (action.uri != null &&
          action.uri.isNotEmpty &&
          action.userName != null &&
          action.userName.isNotEmpty) {
        final newCredentials =
            AutofillCredential(action.uri, action.userName, action.resourceId);
        await Autofill.addCredentials([newCredentials]);
      }
    }

    return response;
  }
}
