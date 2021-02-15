// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_entities.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_interactor.dart';

abstract class BaseResourceCrudBloc implements Bloc<BlocState> {}

class ResourceCrudBloc extends DefaultBloc<BlocState>
    implements BaseResourceCrudBloc {
  final BaseResourceCrudInteractor _interactor;
  final ResourceCrudModuleIn _moduleIn;
  BaseResourceCrudState _state = ResourceCrudState();
  final _logger = Logger("ResourceCrudBloc");

  ResourceCrudBloc(this._interactor, this._moduleIn) {
    this.actions[CreateResourceIntent] = (intent) async {
      try {
        if (_state is PendingState) {
          return null;
        }

        setState(PendingState());

        final response =
        await _interactor.createResource(intent as CreateResourceIntent);
        setReaction(ResourceCreatedReaction(response.resource));
      } catch (error) {
        setState(ResourceCrudState());
        setReaction(ErrorReaction(error.toString()));
      }
    };

    this.actions[UpdateResourceIntent] = (intent) async {
      try {
        if (_state is PendingState) {
          return null;
        }

        setState(PendingState());

        final response =
            await _interactor.updateResource(_moduleIn.resource, intent as UpdateResourceIntent);
        setReaction(ResourceUpdatedReaction(response.resource));
      } catch (error) {
        setState(ResourceCrudState());
        setReaction(ErrorReaction(error.toString()));
      }
    };
  }
}
