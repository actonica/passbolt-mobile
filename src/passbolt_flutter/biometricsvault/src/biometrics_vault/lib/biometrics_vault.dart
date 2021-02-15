// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

const MethodChannel _channel = MethodChannel('com.actonica.biometrics_vault');

abstract class BiometricsVaultResult {
  static final String success = 'Success';
}

abstract class BiometricsVaultErrorCode {
  static final String unrecoverableKey = 'UnrecoverableKey';
  static final String keyPermanentlyInvalidated = 'KeyPermanentlyInvalidated';
  static final String unavailable = 'Unavailable';
  static final String unknownError = 'UnknownError';
  static final String canceled = 'Canceled';
}

class BiometricsVault {
  static Future<String> getSecretWithBiometrics({
    @required String instructions,
    @required String key,
    @required String accessGroupId,
  }) async {
    assert(instructions != null);
    assert(key != null);
    final Map<String, Object> args = <String, Object>{
      'instructions': instructions,
      'key': key,
      'accessGroupId': accessGroupId
    };
    return await _channel.invokeMethod<String>('getSecretWithBiometrics', args);
  }

  static Future<String> setSecretWithBiometrics({
    @required String instructions,
    @required String key,
    @required String clear,
    @required String accessGroupId,
  }) async {
    assert(instructions != null);
    assert(key != null);
    assert(clear != null);
    final Map<String, Object> args = <String, Object>{
      'instructions': instructions,
      'key': key,
      'clear': clear,
      'accessGroupId': accessGroupId
    };
    return await _channel.invokeMethod<String>('setSecretWithBiometrics', args);
  }

  static Future<String> deleteSecretWithBiometrics({
    @required String instructions,
    @required String key,
    @required String accessGroupId,
  }) async {
    assert(instructions != null);
    assert(key != null);
    final Map<String, Object> args = <String, Object>{
      'instructions': instructions,
      'key': key,
      'accessGroupId': accessGroupId
    };
    return await _channel.invokeMethod<String>(
        'deleteSecretWithBiometrics', args);
  }
}
