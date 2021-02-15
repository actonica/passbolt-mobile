// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';

part 'passbolt_permission.g.dart';

@JsonSerializable()
class PassboltPermission {
  final String id;
  final String aco; // Access control object - resource
  final String aco_foreign_key;
  final String aro; // Access request object - user or group
  final String aro_foreign_key;
  final int type; // 1 - Read, 7 - Update, 15 - Owner
  final String created;
  final String modified;

  PassboltPermission(
    this.id,
    this.aco,
    this.aco_foreign_key,
    this.aro,
    this.aro_foreign_key,
    this.type,
    this.created,
    this.modified,
  );

  factory PassboltPermission.fromJson(Map<String, dynamic> json) =>
      _$PassboltPermissionFromJson(json);
}
