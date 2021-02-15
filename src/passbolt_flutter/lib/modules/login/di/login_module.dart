// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/autofill_hints_provider.dart';
import 'package:passbolt_flutter/data/providers/autofill_values_provider.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';
import 'package:passbolt_flutter/modules/login/login_api.dart';
import 'package:passbolt_flutter/modules/login/login_bloc.dart';
import 'package:passbolt_flutter/modules/login/login_entities.dart';
import 'package:passbolt_flutter/modules/login/login_interactor.dart';

@module
class LoginDiModule {
  @provide
  @singleton
  BaseLoginApi api(
          BaseHttpClientProvider httpClientProvider,
          BaseSecureStorageProvider secureStorageProvider,
          BaseCookiesProvider cookiesProvider,
          BaseUsersProvider usersProfileProvider,
          Connectivity connectivity) =>
      LoginApi(httpClientProvider, secureStorageProvider, cookiesProvider,
          usersProfileProvider, connectivity);

  @provide
  @singleton
  BaseLoginInteractor interactor(
    BaseLoginApi loginApi,
    BaseAutofillHintsProvider autofillHintsProvider,
    BaseAutofillValuesProvider autofillValuesProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BasePassphraseProvider passphraseProvider,
    BaseSettingsProvider settingsProvider,
    FirebaseAnalytics firebaseAnalytics,
  ) =>
      LoginInteractor(
        loginApi,
        autofillHintsProvider,
        autofillValuesProvider,
        secureStorageProvider,
        passphraseProvider,
        settingsProvider,
        firebaseAnalytics,
      );

  @provide
  @singleton
  LoginBloc bloc(BaseLoginInteractor interactor) =>
      LoginBloc(interactor)..add(GetInitStateEvent());
}
