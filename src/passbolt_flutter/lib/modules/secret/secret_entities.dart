// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/entities/comment.dart';
import 'package:passbolt_flutter/data/entities/permission_with_aro.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';

class UpdateModuleInIntent extends UserIntent {
  final Resource resource;

  UpdateModuleInIntent(this.resource);
}

class FetchSecretDetailsIntent extends UserIntent {}

class DeleteResourceIntent extends UserIntent {}

class SecretModuleIn {
  final Resource resource;

  SecretModuleIn(this.resource);
}

class BaseSecretState implements BlocState {
  final Resource resource;

  BaseSecretState(this.resource);
}

class SecretState extends BaseSecretState {
  final String decryptedSecret;
  final List<AroPermission> aroPermissions;
  final List<Comment> comments;

  SecretState(
    this.decryptedSecret,
    this.aroPermissions,
    this.comments,
    Resource resource,
  ) : super(resource);
}

class PendingSecretState extends BaseSecretState {
  PendingSecretState(Resource resource) : super(resource);
}

class PendingDeleteResourceState extends BaseSecretState {
  PendingDeleteResourceState(Resource resource) : super(resource);
}

class DeleteCompleteReaction extends BlocReaction {}
