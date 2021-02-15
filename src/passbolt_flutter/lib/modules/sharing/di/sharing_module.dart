// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/providers/groups_provider.dart';
import 'package:passbolt_flutter/data/providers/permissions_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_bloc.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_entities.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_interactor.dart';

@module
class SharingDiModule {
  final SharingModuleIn _moduleIn;

  SharingDiModule(this._moduleIn);

  @provide
  @singleton
  BaseSharingInteractor interactor(
    BaseSharingApi sharingApi,
    BasePermissionsProvider permissionsProvider,
    BaseUsersProvider usersProvider,
    BaseGroupsProvider groupsProvider,
  ) =>
      SharingInteractor(
        sharingApi,
        permissionsProvider,
        usersProvider,
        groupsProvider,
      );

  @provide
  @singleton
  BaseSharingBloc bloc(
          SharingModuleIn moduleIn, BaseSharingInteractor interactor) =>
      SharingBloc(moduleIn, interactor);

  @provide
  SharingModuleIn moduleIn() => _moduleIn;
}
