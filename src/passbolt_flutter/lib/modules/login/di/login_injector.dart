// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/login/di/login_module.dart';
import 'package:passbolt_flutter/modules/login/login_widget.dart';

import 'login_injector.inject.dart' as generated;

@Injector([LoginDiModule, AppDiModule])
abstract class LoginInjector {
  static final createSync = generated.LoginInjector$Injector.createSync;

  @provide
  LoginWidget widget();
}
