// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/common/bloc.dart';

class ChangeLoginWithBiometricsIntent extends UserIntent {
  final bool value;

  ChangeLoginWithBiometricsIntent(this.value);
}

class LoginWithBiometricsModuleIn {
  final String title;
  final bool currentValue;

  LoginWithBiometricsModuleIn(this.title, this.currentValue);
}

class LoginWithBiometricsState extends BlocState {
  final bool currentValue;

  LoginWithBiometricsState(this.currentValue);
}
