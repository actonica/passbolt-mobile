// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:passbolt_flutter/i18n/app_i18n.dart';

class AppI18nDelegate extends LocalizationsDelegate<AppI18n> {
  const AppI18nDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppI18n.supportedLocales
        .map(
          (locale) {
            return locale.languageCode;
          },
        )
        .toList()
        .contains(locale.languageCode);
  }

  @override
  Future<AppI18n> load(Locale locale) {
    return SynchronousFuture<AppI18n>(AppI18n(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppI18n> old) {
    return false;
  }
}
