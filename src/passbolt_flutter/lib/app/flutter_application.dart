// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/app/application.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/i18n/app_i18n.dart';
import 'package:passbolt_flutter/i18n/app_i18n_delegate.dart';

class FlutterApplication extends StatefulWidget {
  final StateFlutterApplication _state;

  FlutterApplication(this._state);

  @override
  State<FlutterApplication> createState() {
    return _state;
  }
}

class StateFlutterApplication extends State<FlutterApplication> {
  final String _appName;
  final ThemeDataProvider _themeDataProvider;
  final _logger = Logger("StateFlutterApplication");

  StateFlutterApplication(this._appName, this._themeDataProvider);

  @override
  void initState() {
    super.initState();

    Logger.root.onRecord.listen(
      (LogRecord record) {
        if (record.error != null) {
          debugPrint(
              '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}: ${record.error}');
        } else {
          debugPrint(
              '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
        }
      },
    );

    if (_application == null) {
      _application = Application();
    }
  }

  Application _application;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        const AppI18nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppI18n.supportedLocales,
      theme: _themeDataProvider.lightThemeData,
      title: _appName,
      home: _application,
    );
  }
}
