// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/common/bloc.dart';

class ImportKeyIntent extends UserIntent {
  final String privateKey;

  ImportKeyIntent(this.privateKey);
}

abstract class BaseImportKeyState implements BlocState {}

class ImportKeyState implements BaseImportKeyState {}

class NavigateToLoginReaction extends BlocReaction {}
