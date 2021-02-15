// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';
import 'package:passbolt_flutter/data/entities/passbolt_group_user.dart';

part 'passbolt_group.g.dart';

@JsonSerializable()
class PassboltGroup {
  final String id;
  final String name;
  final String created;
  final String created_by;
  final bool deleted;
  final String modified;
  final String modified_by;
  final List<PassboltGroupUser> users;

  PassboltGroup(
    this.id,
    this.name,
    this.created,
    this.created_by,
    this.deleted,
    this.modified,
    this.modified_by,
    this.users,
  );

  factory PassboltGroup.fromJson(Map<String, dynamic> json) =>
      _$PassboltGroupFromJson(json);
}
