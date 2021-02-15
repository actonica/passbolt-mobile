// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/providers/settings_provider.dart';

class AutoLogoutModuleIn {
  final String title;
  final AutoLogoutPreset currentValue;

  AutoLogoutModuleIn(this.title, this.currentValue);
}