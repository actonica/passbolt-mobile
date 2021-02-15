// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/profile/di/profile_module.dart';
import 'package:passbolt_flutter/modules/profile/profile_widget.dart';

import 'profile_injector.inject.dart' as generated;

@Injector([ProfileDiModule, AppDiModule])
abstract class ProfileInjector {
  static final createSync = generated.ProfileInjector$Injector.createSync;

  @provide
  ProfileWidget widget();
}
