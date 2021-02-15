// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/auto_logout_bloc.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/auto_logout_entities.dart';

@module
class AutoLogoutDiModule {
  final AutoLogoutModuleIn _moduleIn;

  AutoLogoutDiModule(this._moduleIn);

  @provide
  @singleton
  BaseAutoLogoutBloc bloc(BaseSettingsProvider settingsProvider) =>
      AutoLogoutBloc(settingsProvider);

  @provide
  @singleton
  AutoLogoutModuleIn moduleIn() => this._moduleIn;
}
