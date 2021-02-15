// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';
import 'package:passbolt_flutter/data/entities/passbolt_permission.dart';

part 'passbolt_resource.g.dart';

@JsonSerializable()
class PassboltResource {
  final String id;
  final String created;
  @JsonKey(name: "created_by")
  final String createdBy;
  final bool deleted;
  final String description;
  final String favorite;
  final String modified;
  @JsonKey(name: "modified_by")
  final String modifiedBy;
  final String name;
  final String uri;
  final String username;
  final PassboltPermission permission;

  PassboltResource(
    this.id,
    this.created,
    this.createdBy,
    this.deleted,
    this.description,
    this.favorite,
    this.modified,
    this.modifiedBy,
    this.name,
    this.uri,
    this.username,
    this.permission,
  );

  factory PassboltResource.fromJson(Map<String, dynamic> json) =>
      _$PassboltResourceFromJson(json);
}
