// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/api/comments_api.dart';
import 'package:passbolt_flutter/data/api/permissions_api.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_entities.dart';
import 'package:passbolt_flutter/modules/secret/secret_interactor.dart';

abstract class BaseSecretBloc implements Bloc<BlocState> {}

class SecretBloc extends DefaultBloc<BlocState> implements BaseSecretBloc {
  final BaseSecretInteractor _interactor;
  SecretState _persistentState;
  final _logger = Logger("SecretBloc");

  SecretBloc(SecretModuleIn moduleIn, this._interactor)
      : _persistentState = SecretState(null, null, null, moduleIn.resource) {
    this.actions[FetchSecretDetailsIntent] = (intent) async {
      if (this.state is PendingSecretState) {
        return;
      }

      setState(PendingSecretState(_persistentState.resource));

      final secretResponse = await _interactor.getSecret(
        GetSecretRequest(_persistentState.resource.id),
      );

      final commentsResponse = await _interactor.getComments(
        GetCommentsRequest(_persistentState.resource.id),
      );

      final permissionsResponse = await _interactor.getPermissions(
        GetPermissionsRequest(_persistentState.resource.id),
      );
      _persistentState = SecretState(
        secretResponse.decryptedSecret,
        permissionsResponse,
        commentsResponse.comments,
        _persistentState.resource,
      );
      setState(_persistentState);
    };

    this.actions[UpdateModuleInIntent] = (intent) async {
      if ((intent as UpdateModuleInIntent).resource == null) return;

      _persistentState = SecretState(
        _persistentState.decryptedSecret,
        _persistentState.aroPermissions,
        _persistentState.comments,
        (intent as UpdateModuleInIntent).resource,
      );
      setState(_persistentState);
    };

    this.actions[DeleteResourceIntent] = (intent) async {
      if (this.state is PendingDeleteResourceState) {
        return;
      }

      setState(PendingDeleteResourceState(_persistentState.resource));

      try {
        await _interactor.deleteResource(
          DeleteResourceRequest(_persistentState.resource.id),
        );

        setReaction(DeleteCompleteReaction());
      } catch (error) {
        setReaction(ErrorReaction(error.toString()));
      } finally {
        setState(_persistentState);
      }
    };
  }
}
