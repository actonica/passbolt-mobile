// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';

class FetchPermissionsIntent extends UserIntent {}

class SearchAroIntent extends UserIntent {
  final String input;

  SearchAroIntent(this.input);
}

class DeleteAroPermissionIntent extends UserIntent {
  final AroPermission aroPermission;

  DeleteAroPermissionIntent(this.aroPermission);
}

class EditPermissionIntent extends UserIntent {
  final AroPermission aroPermission;
  final PermissionType permissionType;

  EditPermissionIntent(this.aroPermission, this.permissionType);
}

class AddDefaultPermissionIntent extends UserIntent {
  final Aro aro;

  AddDefaultPermissionIntent(this.aro);
}

class ApplyChangesIntent extends UserIntent {}

class NavigateBackIntent extends UserIntent {}

abstract class AroItem {}

class AroNoResults implements AroItem {}

class AroPending implements AroItem {}

class AroError implements AroItem {
  final String message;

  AroError(this.message);
}

class SharingModuleIn {
  final String resourceId;
  final String password;

  SharingModuleIn(this.resourceId, this.password);
}

abstract class BaseSharingState implements BlocState {}

class SharingState implements BaseSharingState {
  final List<AroPermission> permissions;
  final List<AroItem> aros;
  final bool isChanged;

  SharingState(this.permissions, this.isChanged, [this.aros]);
}

class SharingPendingAroState extends SharingState {
  SharingPendingAroState(
      List<AroPermission> permissions, bool isChanged, List<AroItem> aros)
      : super(permissions, isChanged, aros);
}

class AlreadyInListReaction extends BlocReaction {}

class PasswordMustHaveAnOwnerReaction extends BlocReaction {}

class ApplyChangesCompleteReaction extends BlocReaction {}

class NavigateBackReaction extends BlocReaction {
  final bool hasChanged;

  NavigateBackReaction(this.hasChanged);
}
