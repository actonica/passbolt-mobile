// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/resources/di/resources_module.dart';
import 'package:passbolt_flutter/modules/resources/resources_widget.dart';

import 'resources_injector.inject.dart' as generated;

@Injector([ResourcesDiModule, AppDiModule])
abstract class ResourcesInjector {
  static final createSync = generated.ResourcesInjector$Injector.createSync;

  @provide
  ResourcesWidget widget();
}
