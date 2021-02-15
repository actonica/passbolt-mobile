// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/foundation.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';

enum ResourceCrudMode { create, edit }

class ResourceCrudModuleIn {
  final ResourceCrudMode mode;
  final Resource resource;
  final String decryptedPassword;

  ResourceCrudModuleIn(this.mode, [this.resource, this.decryptedPassword]);
}

class CreateResourceIntent extends UserIntent {
  final String name;
  final String uri;
  final String userName;
  final String password;
  final String description;

  CreateResourceIntent({
    @required this.name,
    this.uri,
    this.userName,
    @required this.password,
    this.description,
  });
}

class UpdateResourceIntent extends UserIntent {
  final String resourceId;
  final String name;
  final String uri;
  final String userName;
  final String password;
  final String description;

  UpdateResourceIntent({
    @required this.resourceId,
    @required this.name,
    this.uri,
    this.userName,
    @required this.password,
    this.description,
  });
}

abstract class BaseResourceCrudState implements BlocState {}

class ResourceCrudState implements BaseResourceCrudState {}

class ResourceCreatedReaction extends BlocReaction {
  final Resource resource;

  ResourceCreatedReaction(this.resource);
}

class ResourceUpdatedReaction extends BlocReaction {
  final Resource resource;

  ResourceUpdatedReaction(this.resource);
}
