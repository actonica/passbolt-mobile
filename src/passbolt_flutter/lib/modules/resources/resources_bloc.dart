// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/modules/resources/resources_api.dart';
import 'package:passbolt_flutter/modules/resources/resources_entities.dart';
import 'package:passbolt_flutter/modules/resources/resources_interactor.dart';

abstract class BaseResourcesBloc implements Bloc<BlocState> {}

class ResourcesBloc extends DefaultBloc<BlocState>
    implements BaseResourcesBloc {
  final BaseResourcesInteractor _interactor;
  final _state = ResourcesState();
  final _logger = Logger("ResourcesBloc");

  ResourcesBloc(this._interactor) {
    this.actions[FetchResourcesIntent] = (intent) async {
      final resourcesResponse =
          await _interactor.getResources(GetResourcesRequest());
      _state.rawResources = resourcesResponse.resources;
      _state.resources = _sort();
      setState(_state);
    };

    this.actions[FilterIntent] = (intent) async {
      final filterIntent = intent as FilterIntent;

      if (filterIntent.filter == null) return;

      final copyResources = _sort();
      copyResources.removeWhere(
        (resource) {
          final inputLowerCase = filterIntent.filter.toLowerCase();
          return !resource.name.toLowerCase().contains(inputLowerCase) &&
              !(resource.username?.toLowerCase()?.contains(inputLowerCase) ??
                  false) &&
              !(resource.uri?.toLowerCase()?.contains(inputLowerCase) ??
                  false) &&
              !(resource.description?.toLowerCase()?.contains(inputLowerCase) ??
                  false);
        },
      );
      _state.resources = copyResources;
      setState(_state);
    };
  }

  List<Resource> _sort() {
    final copyResources = List<Resource>();
    copyResources.insertAll(0, _state.rawResources);
    copyResources.sort(_compareResources);

    return copyResources;
  }

  int _compareResources(Resource a, Resource b) {
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
