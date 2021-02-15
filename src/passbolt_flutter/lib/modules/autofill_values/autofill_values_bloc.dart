// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/modules/autofill_values/autofill_values_entities.dart';
import 'package:passbolt_flutter/modules/autofill_values/autofill_values_interactor.dart';

abstract class BaseAutofillValuesBloc implements Bloc<BlocState> {}

class AutofillValuesBloc extends DefaultBloc<BlocState>
    implements BaseAutofillValuesBloc {
  final BaseAutofillValuesInteractor _interactor;
  final _state = AutofillValuesState();
  final _logger = Logger("AutofillValuesBloc");

  AutofillValuesBloc(this._interactor) {
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

    this.actions[GetAutofillValuesIntent] = (intent) async {
      if (_state is PendingState) return;

      setState(PendingState());

      final response = await _interactor.getAutofillValuesOrResources();

      _state.rawResources = response.resources;
      _state.resources = _sort();
      setState(_state);
    };

    this.actions[SelectResourceForAutofillIntent] = (intent) async {
      setState(PendingState());
      await _interactor.selectResourceForAutofill(SelectResourceForAutofillRequest(
          (intent as SelectResourceForAutofillIntent).resource));
    };
  }

  List<Resource> _sort() {
    final copyResources = List<Resource>();
    copyResources.insertAll(0, _state.rawResources);
    copyResources.sort(_compareResources);

    return copyResources;
  }

  int _compareResources(Resource a, Resource b) {
    switch (_state.sortingMode) {
      case SortingMode.ASC:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        break;

      case SortingMode.DESC:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase()) * (-1);
        break;
      default:
        throw StateError("Bad sorting mode");
    }
  }
}
