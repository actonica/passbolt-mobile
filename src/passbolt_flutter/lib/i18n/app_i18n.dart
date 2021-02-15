// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/widgets.dart';

class AppI18n {
  static const supportedLocales = [Locale('en'), Locale('ru')];

  final Locale locale;

  AppI18n(this.locale);

  static AppI18n of(BuildContext context) {
    return Localizations.of<AppI18n>(context, AppI18n);
  }

  static Map<String, Map<AppI18nNames, String>> _localizedValues = {
    'en': {
      AppI18nNames.globalDialogYes: 'Yes',
      AppI18nNames.globalDialogNo: 'No',
      AppI18nNames.globalContinue: 'Continue',
    },
    'ru': {
      AppI18nNames.globalDialogYes: 'Да',
      AppI18nNames.globalDialogNo: 'Нет',
      AppI18nNames.globalContinue: 'Продолжить',
    }
  };

  String string(AppI18nNames name) {
    return _localizedValues[locale.languageCode][name];
  }
}

enum AppI18nNames { globalDialogYes, globalDialogNo, globalContinue }
