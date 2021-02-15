// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/di/app_di_module_provider.dart';
import 'package:passbolt_flutter/modules/autofill_values/di/autofill_values_injector.dart';
import 'package:passbolt_flutter/modules/autofill_values/di/autofill_values_module.dart';
import 'package:passbolt_flutter/modules/import_key/di/import_key_injector.dart';
import 'package:passbolt_flutter/modules/import_key/di/import_key_module.dart';
import 'package:passbolt_flutter/modules/login/di/login_injector.dart';
import 'package:passbolt_flutter/modules/login/di/login_module.dart';
import 'package:passbolt_flutter/modules/profile/di/profile_injector.dart';
import 'package:passbolt_flutter/modules/profile/di/profile_module.dart';
import 'package:passbolt_flutter/modules/resource_crud/di/resource_crud_di_module.dart';
import 'package:passbolt_flutter/modules/resource_crud/di/resource_crud_injector.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_entities.dart';
import 'package:passbolt_flutter/modules/resources/di/resources_injector.dart';
import 'package:passbolt_flutter/modules/resources/di/resources_module.dart';
import 'package:passbolt_flutter/modules/sharing/di/sharing_injector.dart';
import 'package:passbolt_flutter/modules/sharing/di/sharing_module.dart';
import 'package:passbolt_flutter/modules/sharing/sharing_entities.dart';
import 'package:passbolt_flutter/modules/verify_server/di/verify_server_injector.dart';
import 'package:passbolt_flutter/modules/verify_server/di/verify_server_module.dart';

class Router extends Navigator {
  Router({
    @required Key key,
    @required String initialRoute,
    @required RouteFactory onGenerateRoute,
  }) : super(
          key: key,
          initialRoute: initialRoute,
          onGenerateRoute: onGenerateRoute,
        );

  @override
  NavigatorState createState() {
    return RouterState();
  }
}

class RouterState extends NavigatorState with WidgetsBindingObserver {
  final _logger = Logger("_RouterState");
  final List<RouteName> _noLogoutRoutes = [
    RouteName.verifyServer,
    RouteName.importPrivateKey,
    RouteName.login,
    RouteName.autofillValues,
  ];
  AppLifecycleState _previousState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.fine(
        'didChangeAppLifecycleState state $state previousState $_previousState');
    final settingsProvider =
        AppDiModuleProvider.of(context).appDiModule.settingsProvider();

    if (state == AppLifecycleState.paused ||
        (state == AppLifecycleState.inactive &&
            (_previousState == null ||
                _previousState == AppLifecycleState.resumed))) {
      settingsProvider.setProperty(
        SettingsKey.lastActivityTime,
        DateTime.now().millisecondsSinceEpoch,
      );
      _logger.fine('save lastActivityTime to settings');
    } else if (state == AppLifecycleState.resumed) {
      settingsProvider.getSettings().then(
        (Settings settings) {
          if (settings.lastActivityTime == null) {
            _logger.fine('lastActivityTime is null, return');
            return;
          }

          bool screenNeedLogout = false;

          popUntil(
            (e) {
              if (e.isCurrent && _isLogoutRoute(e.settings)) {
                screenNeedLogout = true;
              }

              return true;
            },
          );

          if (screenNeedLogout) {
            _logger.fine('lastActivityTime: ${settings.lastActivityTime}');
            _logger.fine(
              'autologout: ${settings.autoLogoutPreset.milliseconds}',
            );
            _logger.fine(
              'currentTime: ${DateTime.now().millisecondsSinceEpoch}',
            );
            bool needLogout = settings.lastActivityTime +
                    settings.autoLogoutPreset.milliseconds <
                DateTime.now().millisecondsSinceEpoch;
            _logger.fine('needLogout: $needLogout');
            if (needLogout) {
              pushNamedAndRemoveUntil(
                  RouteName.login.toString(), (e) => false);
            }
          }
        },
      );
    }
  }

  bool _isLogoutRoute(RouteSettings routeSettings) {
    try {
      RouteName routeName = RouteName.values.firstWhere(
        (routeName) {
          return routeName.toString() == routeSettings.name;
        },
      );

      return !_noLogoutRoutes.any((e) => routeName == e);
    } catch (error) {
      return true;
    }
  }
}

enum RouteName {
  verifyServer,
  importPrivateKey,
  login,
  autofillValues,
  resources,
  profile,
  resourceCreate,
  resourceUpdate,
  sharing
}

class RouteBuilder {
  static Route build(RouteSettings routeSettings, AppDiModule appDiModule) {
    return CupertinoPageRoute(
      builder: (context) {
        return _buildWidget(routeSettings, appDiModule);
      },
      settings: routeSettings,
    );
  }

  static Widget _buildWidget(
    RouteSettings routeSettings,
    AppDiModule appDiModule,
  ) {
    try {
      RouteName routeName = RouteName.values.firstWhere(
        (e) {
          return e.toString() == routeSettings.name;
        },
      );

      switch (routeName) {
        case RouteName.verifyServer:
          return Theme(
            data: appDiModule.themeDataProvider().darkThemeData,
            child: VerifyServerInjector.createSync(
              VerifyServerDiModule(),
              appDiModule,
            ).widget(),
          );
          break;
        case RouteName.importPrivateKey:
          return Theme(
            data: appDiModule.themeDataProvider().darkThemeData,
            child: ImportKeyInjector.createSync(
              ImportKeyDiModule(),
              appDiModule,
            ).widget(),
          );
          break;
        case RouteName.login:
          return Theme(
            data: appDiModule.themeDataProvider().darkThemeData,
            child:
                LoginInjector.createSync(LoginDiModule(), appDiModule).widget(),
          );
          break;
        case RouteName.autofillValues:
          return AutofillValuesInjector.createSync(
            AutofillValuesDiModule(),
            appDiModule,
          ).widget();
          break;
        case RouteName.resources:
          return ResourcesInjector.createSync(ResourcesDiModule(), appDiModule)
              .widget();
          break;
        case RouteName.profile:
          return ProfileInjector.createSync(ProfileDiModule(), appDiModule)
              .widget();
          break;
        case RouteName.resourceCreate:
          return ResourceCrudInjector.createSync(
            ResourceCrudDiModule(
              ResourceCrudModuleIn(ResourceCrudMode.create),
            ),
            appDiModule,
          ).widget();
          break;
        case RouteName.resourceUpdate:
          return ResourceCrudInjector.createSync(
            ResourceCrudDiModule(
              routeSettings.arguments as ResourceCrudModuleIn,
            ),
            appDiModule,
          ).widget();
          break;
        case RouteName.sharing:
          return SharingInjector.createSync(
            SharingDiModule(
              routeSettings.arguments as SharingModuleIn,
            ),
            appDiModule,
          ).widget();
          break;
        default:
          return Scaffold(
            body: Center(
              child: Text("I can't handle this route"),
            ),
          );
      }
    } catch (error) {
      throw AppException("Invalid route name");
    }
  }
}
