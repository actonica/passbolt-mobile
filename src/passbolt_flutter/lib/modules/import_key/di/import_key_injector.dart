// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/import_key/di/import_key_module.dart';
import 'package:passbolt_flutter/modules/import_key/import_key_widget.dart';

import 'import_key_injector.inject.dart' as generated;

@Injector([ImportKeyDiModule, AppDiModule])
abstract class ImportKeyInjector {
  static final createSync = generated.ImportKeyInjector$Injector.createSync;

  @provide
  ImportKeyWidget widget();
}
