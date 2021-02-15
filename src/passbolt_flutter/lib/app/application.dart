// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';
import 'dart:io';

import 'package:autofill/autofill.dart' as ActonicaAutofill;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:passbolt_flutter/common/router.dart' as router;
import 'package:passbolt_flutter/data/providers/autofill_hints_provider.dart'
    as ActonicaAutofillHintsProvider;
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/di/app_di_module_provider.dart';

class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StateApplication();
  }
}

class _StateApplication extends State<Application> {
  final _logger = Logger("_StateDiProviderHost");
  final _routerKey = GlobalKey<router.RouterState>();
  AppDiModuleProvider _appDiModuleProvider;
  Locale _locale;

  Future<void> _initApplication() async {
    if (_appDiModuleProvider != null) return;

    AppDiModule appDiModule = AppDiModule(_locale);

    final privateKey = await appDiModule
        .secureStorageProvider()
        .getProperty(SecureStorageKey.PRIVATE_KEY_ASC);

    try {
      appDiModule.settingsProvider().init();
    } catch (error) {
      throw AppException('Unable init app settings. Error ${error.toString()}');
    }

    if (Platform.isAndroid) {
      try {
        final autofillHints =
            await ActonicaAutofill.Autofill.getAutofillHints();

        if (autofillHints != null) {
          appDiModule.autofillHintsProvider().autofillHints =
              ActonicaAutofillHintsProvider.AutofillHints.from(autofillHints);
          _logger.fine('Check autofill autofillHints $autofillHints');
          _logger.fine(
            'Check autofill autofillDatasetProvider.autofillHints ${appDiModule.autofillHintsProvider().autofillHints}',
          );
        }
      } catch (error) {
        _logger
            .warning('Check autofill autofillHints error ${error.toString()}');
      }
    }

    String initialRoute;

    if (privateKey != null) {
      initialRoute = router.RouteName.login.toString();
    } else {
      initialRoute = router.RouteName.verifyServer.toString();
    }

    _appDiModuleProvider = AppDiModuleProvider(
      appDiModule,
      WillPopScope(
        onWillPop: () async {
          if (_routerKey.currentState?.canPop() ?? false) {
            await _routerKey.currentState?.maybePop();
            return false;
          } else {
            return true;
          }
        },
        child: router.Router(
          key: _routerKey,
          onGenerateRoute: (routeSettings) {
            return router.RouteBuilder.build(routeSettings, appDiModule);
          },
          initialRoute: initialRoute,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      _locale = Localizations.localeOf(context);
    }

    _logger.info("application rebuild locale = ${_locale.toString()}");

    return FutureBuilder(
      future: _initApplication(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _appDiModuleProvider;
        } else {
          return Container(
            color: Colors.white,
          );
        }
      },
    );
  }
}
