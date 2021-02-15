// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:flutter/services.dart';

class Autofill {
  static const MethodChannel _channel = MethodChannel('autofill');

  // Android only
  static Future<Map<dynamic, dynamic>> getAutofillHints() async {
    // response format - {'autofillIdPackage':'org.mozilla.firefox', 'autofillWebDomain':'gitlab.com', 'hints':[{'hint':'username', 'autofillId':'1245:true:12'}, {...}]}

    final Map<dynamic, dynamic> fields =
        await _channel.invokeMethod('getAutofillHints');
    return fields;
  }

  // Android only
  static Future<void> setAutofillValues(Map<dynamic, dynamic> request) async {
    // request format - {'autofillIdPackage':'org.mozilla.firefox', 'autofillWebDomain':'gitlab.com', 'values':[{'hint':'username', 'labelForHint':'someLabel', 'valueForHint':'someValue', 'autofillId':'1245:true:12'}, {...}]}

    assert(request != null);
    final Map<String, Object> args = <String, Object>{'request': request};

    final Map<dynamic, dynamic> fields =
        await _channel.invokeMethod('setAutofillValues', args);
    return fields;
  }

  // iOS only
  static Future<bool> addCredentials(List<AutofillCredential> request) async {
    assert(request != null);

    final Map<String, List<Map<String, String>>> args = {
      'credentialsData': request.map(
        (AutofillCredential autofillCredential) {
          return {
            'serviceIdentifier': autofillCredential.serviceIdentifier,
            'userName': autofillCredential.userName,
            'recordIdentifier': autofillCredential.recordIdentifier,
          };
        },
      ).toList()
    };

    return await _channel.invokeMethod('addCredentials', args);
  }

  // iOS only
  static Future<bool> removeCredentials(List<AutofillCredential> request) async {
    assert(request != null);

    final Map<String, List<Map<String, String>>> args = {
      'credentialsData': request.map(
            (AutofillCredential autofillCredential) {
          return {
            'serviceIdentifier': autofillCredential.serviceIdentifier,
            'userName': autofillCredential.userName,
            'recordIdentifier': autofillCredential.recordIdentifier,
          };
        },
      ).toList()
    };

    return await _channel.invokeMethod('removeCredentials', args);
  }

  // iOS only
  static Future<bool> removeAllCredentials() async {
    return await _channel.invokeMethod('removeAllCredentials');
  }
}

class AutofillCredential {
  final String serviceIdentifier;
  final String userName;
  final String recordIdentifier;

  AutofillCredential(
    this.serviceIdentifier,
    this.userName,
    this.recordIdentifier,
  );
}
