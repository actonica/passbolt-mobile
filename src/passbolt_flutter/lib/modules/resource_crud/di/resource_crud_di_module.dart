// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/api/permissions_api.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/groups_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_api.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_bloc.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_entities.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_interactor.dart';

@module
class ResourceCrudDiModule {
  final ResourceCrudModuleIn _moduleIn;

  ResourceCrudDiModule(this._moduleIn);

  @provide
  @singleton
  ResourceCrudModuleIn moduleIn() => _moduleIn;

  @provide
  @singleton
  BaseResourceCrudApi api(
          BaseHttpClientProvider httpClientProvider,
          BaseSecureStorageProvider secureStorageProvider,
          BaseCookiesProvider cookiesProvider,
          Connectivity connectivity) =>
      ResourceCrudApi(httpClientProvider, secureStorageProvider,
          cookiesProvider, connectivity);

  @provide
  @singleton
  BaseResourceCrudInteractor interactor(
    BaseResourceCrudApi resourceCrudApi,
    BasePermissionsApi permissionsApi,
    BaseGroupsProvider groupsProvider,
    BaseUsersProvider usersProvider,
  ) =>
      ResourceCrudInteractor(
        resourceCrudApi,
        permissionsApi,
        groupsProvider,
        usersProvider,
      );

  @provide
  @singleton
  BaseResourceCrudBloc bloc(
    BaseResourceCrudInteractor interactor,
    ResourceCrudModuleIn moduleIn,
  ) =>
      ResourceCrudBloc(interactor, moduleIn);
}
