// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';

class SelectResourceForAutofillIntent extends UserIntent {
  final Resource resource;

  SelectResourceForAutofillIntent(this.resource);
}

class GetAutofillValuesIntent extends UserIntent {}

class FilterIntent extends UserIntent {
  final String filter;

  FilterIntent(this.filter);
}

abstract class BaseAutofillValuesState implements BlocState {}

class AutofillValuesState implements BaseAutofillValuesState {
  SortingMode sortingMode = SortingMode.ASC;
  String avatarUrl;
  List<Resource> resources;
  List<Resource> rawResources;
}

enum SortingMode { ASC, DESC }
