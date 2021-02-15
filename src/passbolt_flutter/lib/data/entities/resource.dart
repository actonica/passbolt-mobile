// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/entities/passbolt_resource.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';

class Resource {
  final String id;
  final String created;
  final String creator;
  final String description;
  final String modified;
  final String modifier;
  final String name;
  final String username;
  final String uri;
  final PermissionType permissionType;

  Resource(
    this.id,
    this.created,
    this.creator,
    this.description,
    this.modified,
    this.modifier,
    this.name,
    this.username,
    this.uri,
    this.permissionType,
  );

  factory Resource.from(PassboltResource resource) => Resource(
      resource.id,
      resource.created,
      resource.createdBy,
      resource.description,
      resource.modified,
      resource.modifiedBy,
      resource.name,
      resource.username,
      resource.uri,
      Permission.parse(resource.permission.type));

  @override
  String toString() {
    return 'Resource{id: $id, created: $created, creator: $creator, description: $description, modified: $modified, modifier: $modifier, name: $name, username: $username, uri: $uri, permissionType: $permissionType}';
  }
}
