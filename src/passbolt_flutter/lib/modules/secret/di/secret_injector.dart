// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/resource_crud/di/resource_crud_di_module.dart';
import 'package:passbolt_flutter/modules/secret/di/secret_module.dart';
import 'package:passbolt_flutter/modules/secret/secret_widget.dart';

import 'secret_injector.inject.dart' as generated;

@Injector([SecretDiModule, ResourceCrudDiModule, AppDiModule])
abstract class SecretInjector {
  static final createSync = generated.SecretInjector$Injector.createSync;

  @provide
  SecretWidget widget();
}
