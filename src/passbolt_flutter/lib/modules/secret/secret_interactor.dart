// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:openpgp/openpgp.dart';
import 'package:passbolt_flutter/common/decrypt.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/api/comments_api.dart';
import 'package:passbolt_flutter/data/api/permissions_api.dart';
import 'package:passbolt_flutter/data/entities/comment.dart';
import 'package:passbolt_flutter/data/entities/passbolt_comment.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/permissions_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_api.dart';
import 'package:passbolt_flutter/tools/values_converter.dart';

class DecryptRequest {
  final String encryptedSecret;

  DecryptRequest(this.encryptedSecret);
}

class DecryptResponse {
  final String decryptedSecret;

  DecryptResponse(this.decryptedSecret);
}

class GetCommentsResponse {
  final List<Comment> comments;

  GetCommentsResponse(this.comments);
}

abstract class BaseSecretInteractor implements Interactor {
  Future<DeleteResourceResponse> deleteResource(DeleteResourceRequest request);

  Future<GetCommentsResponse> getComments(GetCommentsRequest request);

  Future<List<AroPermission>> getPermissions(GetPermissionsRequest request);

  Future<DecryptResponse> getSecret(GetSecretRequest request);
}

class SecretInteractor implements BaseSecretInteractor {
  final BaseSecretApi _secretApi;
  final BaseResourceCrudApi _resourceCrudApi;
  final BaseCommentsApi _commentsApi;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BasePassphraseProvider _passphraseProvider;
  final BasePermissionsProvider _permissionsProvider;
  final BaseUsersProvider _usersProvider;

  final _logger = Logger("SecretInteractor");

  SecretInteractor(
    this._secretApi,
    this._resourceCrudApi,
    this._commentsApi,
    this._secureStorageProvider,
    this._passphraseProvider,
    this._permissionsProvider,
    this._usersProvider,
  );

  @override
  Future<DeleteResourceResponse> deleteResource(DeleteResourceRequest request) {
    return _resourceCrudApi.deleteResource(request);
  }

  @override
  Future<GetCommentsResponse> getComments(GetCommentsRequest request) async {
    final wsResponse = await _commentsApi.getComments(request);

    final comments = List<Comment>();

    await Future.forEach(
      wsResponse.comments,
      (PassboltComment passboltComment) async {
        final user = await _usersProvider.getUser(passboltComment.user_id);
        final String diff =
            ValuesConverter.toTimeFromNow(passboltComment.created);

        comments.add(
          Comment(
            '${user.profile.firstName} ${user.profile.lastName}',
            user.profile.avatarUrl,
            passboltComment.content,
            diff ?? passboltComment.created,
          ),
        );
      },
    );

    return GetCommentsResponse(comments);
  }

  @override
  Future<List<AroPermission>> getPermissions(GetPermissionsRequest request) {
    return _permissionsProvider.getPermissions(request);
  }

  @override
  Future<DecryptResponse> getSecret(GetSecretRequest request) async {
    await _usersProvider.getUsersWithAccess(request.resourceId);

    final privateKey = await _secureStorageProvider
        .getProperty(SecureStorageKey.PRIVATE_KEY_ASC);
    final getSecretResponse = await _secretApi.getSecret(request);
    final decryptedSecret = await decryptOpenPgpJsMessage(
      getSecretResponse.secret.encryptedData,
      privateKey,
      _passphraseProvider.passphrase,
    );
    return DecryptResponse(decryptedSecret);
  }
}
