// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/resource_crud/di/resource_crud_di_module.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_widget.dart';

import 'resource_crud_injector.inject.dart' as generated;

@Injector([ResourceCrudDiModule, AppDiModule])
abstract class ResourceCrudInjector {
  static final createSync = generated.ResourceCrudInjector$Injector.createSync;

  @provide
  ResourceCrudWidget widget();
}
