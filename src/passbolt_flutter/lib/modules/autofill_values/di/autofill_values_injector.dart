// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/modules/autofill_values/autofill_values_widget.dart';
import 'package:passbolt_flutter/modules/autofill_values/di/autofill_values_module.dart';

import 'autofill_values_injector.inject.dart' as generated;

@Injector([AutofillValuesDiModule, AppDiModule])
abstract class AutofillValuesInjector {
  static final createSync = generated.AutofillValuesInjector$Injector.createSync;

  @provide
  AutofillValuesWidget widget();
}
