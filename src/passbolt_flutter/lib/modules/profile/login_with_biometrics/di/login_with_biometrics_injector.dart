// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/di/login_with_biometrics_module.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/login_with_biometrics_widget.dart';

import 'login_with_biometrics_injector.inject.dart' as generated;

@Injector([LoginWithBiometricsDiModule, AppDiModule])
abstract class LoginWithBiometricsInjector {
  static final createSync = generated.LoginWithBiometricsInjector$Injector.createSync;

  @provide
  LoginWithBiometricsWidget widget();
}
