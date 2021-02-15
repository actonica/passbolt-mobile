// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/exceptions.dart';

class CheckIntent extends UserIntent {
  final String url;
  final String fingerprint;

  CheckIntent(this.url, this.fingerprint);

  @override
  bool validate() {
    if (url == null || url.isEmpty) {
      throw UserIntentValidationException('Url must be provided');
    }

    if (fingerprint == null || fingerprint.isEmpty) {
      throw UserIntentValidationException(
          'Public key fingerprint must be provided');
    }

    return true;
  }
}

abstract class BaseVerifyServerState implements BlocState {}

class VerifyServerState implements BaseVerifyServerState {}

class NavigateToImportKeyReaction extends BlocReaction {}
