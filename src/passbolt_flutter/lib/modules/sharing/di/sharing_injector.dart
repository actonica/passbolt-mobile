// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/sharing/di/sharing_module.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_widget.dart';

import 'sharing_injector.inject.dart' as generated;

@Injector([SharingDiModule, AppDiModule])
abstract class SharingInjector {
  static final createSync = generated.SharingInjector$Injector.createSync;

  @provide
  SharingWidget widget();
}
