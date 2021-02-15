// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';

part 'passbolt_role.g.dart';

@JsonSerializable()
class PassboltRole {
  final String id;
  final String name;
  final String description;
  final String created;
  final String modified;

  PassboltRole(
    this.id,
    this.name,
    this.description,
    this.created,
    this.modified,
  );

  factory PassboltRole.fromJson(Map<String, dynamic> json) =>
      _$PassboltRoleFromJson(json);
}
