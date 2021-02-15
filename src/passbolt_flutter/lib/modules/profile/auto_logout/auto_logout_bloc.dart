// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/providers/settings_provider.dart';

abstract class BaseAutoLogoutBloc {
  Future<bool> updateAutoLogout(AutoLogoutPreset preset);
}

class AutoLogoutBloc implements BaseAutoLogoutBloc {
  final BaseSettingsProvider _settingsProvider;

  AutoLogoutBloc(this._settingsProvider);

  @override
  Future<bool> updateAutoLogout(AutoLogoutPreset preset) async {
    try {
      await _settingsProvider.setProperty(
          SettingsKey.autoLogout, preset.milliseconds);
      return true;
    } catch (error) {
      return false;
    }
  }
}
