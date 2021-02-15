// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/auto_logout_widget.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/di/auto_logout_module.dart';

import 'auto_logout_injector.inject.dart' as generated;

@Injector([AutoLogoutDiModule, AppDiModule])
abstract class AutoLogoutInjector {
  static final createSync = generated.AutoLogoutInjector$Injector.createSync;

  @provide
  AutoLogoutWidget widget();
}
