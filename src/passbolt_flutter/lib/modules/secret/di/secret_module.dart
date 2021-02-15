// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/api/comments_api.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/permissions_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_bloc.dart';
import 'package:passbolt_flutter/modules/secret/secret_entities.dart';
import 'package:passbolt_flutter/modules/secret/secret_interactor.dart';

@module
class SecretDiModule {
  final SecretModuleIn _moduleIn;

  SecretDiModule(this._moduleIn);

  @provide
  @singleton
  BaseSecretInteractor interactor(
    BaseSecretApi secretApi,
    BaseResourceCrudApi resourceCrudApi,
    BaseCommentsApi commentsApi,
    BaseSecureStorageProvider secureStorageProvider,
    BasePassphraseProvider passphraseProvider,
    BasePermissionsProvider permissionsProvider,
    BaseUsersProvider usersProvider,
  ) =>
      SecretInteractor(
          secretApi,
          resourceCrudApi,
          commentsApi,
          secureStorageProvider,
          passphraseProvider,
          permissionsProvider,
          usersProvider);

  @provide
  @singleton
  BaseSecretBloc bloc(
          SecretModuleIn moduleIn, BaseSecretInteractor interactor) =>
      SecretBloc(moduleIn, interactor);

  @provide
  @singleton
  SecretModuleIn moduleIn() => _moduleIn;
}
