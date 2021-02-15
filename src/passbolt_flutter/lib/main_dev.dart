// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info/package_info.dart';
import 'package:passbolt_flutter/app/flutter_application.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;

  final appName = (await PackageInfo.fromPlatform()).appName;
  final themeProvider = ThemeDataProvider();
  runApp(FlutterApplication(StateFlutterApplication(appName, themeProvider)));
}
