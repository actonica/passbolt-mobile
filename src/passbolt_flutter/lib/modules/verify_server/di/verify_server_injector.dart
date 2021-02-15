// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/verify_server/di/verify_server_module.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_widget.dart';

import 'verify_server_injector.inject.dart' as generated;

@Injector([VerifyServerDiModule, AppDiModule])
abstract class VerifyServerInjector {
  static final createSync = generated.VerifyServerInjector$Injector.createSync;

  @provide
  VerifyServerWidget widget();
}
