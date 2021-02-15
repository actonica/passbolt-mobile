// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/material.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';

class AppDiModuleProvider extends InheritedWidget {
  static AppDiModuleProvider of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppDiModuleProvider>();

    if (result != null) {
      return result;
    } else {
      throw StateError("Widget tree does'n contain AppDiModuleProvider");
    }
  }

  final AppDiModule appDiModule;

  AppDiModuleProvider(this.appDiModule, Widget child) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
