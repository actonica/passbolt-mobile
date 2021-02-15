// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/groups_provider.dart';
import 'package:passbolt_flutter/modules/resources/resources_api.dart';
import 'package:passbolt_flutter/modules/resources/resources_bloc.dart';
import 'package:passbolt_flutter/modules/resources/resources_interactor.dart';

@module
class ResourcesDiModule {
  @provide
  @singleton
  BaseResourcesInteractor interactor(
    BaseResourcesApi api,
    BaseGroupsProvider baseGroupsProvider,
  ) =>
      ResourcesInteractor(api, baseGroupsProvider);

  @provide
  @singleton
  BaseResourcesBloc bloc(BaseResourcesInteractor interactor) =>
      ResourcesBloc(interactor);
}
