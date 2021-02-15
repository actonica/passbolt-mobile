// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/entities/passbolt_permission.dart';

enum AroType {
  user, group
}

class Permission {
  static PermissionType parse(int type) {
    switch (type) {
      case 1:
        return PermissionType.read;
        break;
      case 7:
        return PermissionType.update;
        break;
      case 15:
        return PermissionType.owner;
        break;
      default:
        throw UnimplementedError();
    }
  }

  bool isNew = false;
  final String id;
  final String resourceId;
  final String resourceName;
  final String aroId;
  final AroType aroType;
  final PermissionType type;

  Permission(
    this.id,
    this.resourceId,
    this.resourceName,
    this.aroId,
    this.aroType,
    this.type,
  );

  factory Permission.from(PassboltPermission permission) => Permission(
        permission.id,
        permission.aco_foreign_key,
        permission.aco,
        permission.aro_foreign_key,
        permission.aro == 'User' ? AroType.user : AroType.group,
        parse(permission.type),
      );

  Permission copyWithType(PermissionType type) => Permission(
    this.id,
    this.resourceId,
    this.resourceName,
    this.aroId,
    this.aroType,
    type
  );
}

enum PermissionType { read, update, owner }

extension PermissionTypeExtension on PermissionType {
  String get description {
    switch (this) {
      case PermissionType.read:
        return 'read';
        break;
      case PermissionType.update:
        return 'update';
        break;
      case PermissionType.owner:
        return 'owner';
        break;
      default:
        throw UnimplementedError();
    }
  }

  String get longDescription {
    switch (this) {
      case PermissionType.read:
        return 'can read';
        break;
      case PermissionType.update:
        return 'can update';
        break;
      case PermissionType.owner:
        return 'is owner';
        break;
      default:
        throw UnimplementedError();
    }
  }

  int get intFromType {
    switch (this) {
      case PermissionType.read:
        return 1;
        break;
      case PermissionType.update:
        return 7;
        break;
      case PermissionType.owner:
        return 15;
        break;
      default:
        throw UnimplementedError();
    }
  }
}
