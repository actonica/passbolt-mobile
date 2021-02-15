// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';

class FetchResourcesIntent extends UserIntent {}

class FilterIntent extends UserIntent {
  final String filter;

  FilterIntent(this.filter);
}

abstract class BaseResourcesState implements BlocState {}

class ResourcesState implements BaseResourcesState {
  List<Resource> resources;
  List<Resource> rawResources;
}
