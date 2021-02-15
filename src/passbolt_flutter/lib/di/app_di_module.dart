// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/api/comments_api.dart';
import 'package:passbolt_flutter/data/api/gpg_keys_api.dart';
import 'package:passbolt_flutter/data/api/groups_api.dart';
import 'package:passbolt_flutter/data/api/permissions_api.dart';
import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/api/users_api.dart';
import 'package:passbolt_flutter/data/providers/autofill_hints_provider.dart';
import 'package:passbolt_flutter/data/providers/autofill_values_provider.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/groups_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart'
    as http;
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/permissions_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';
import 'package:passbolt_flutter/modules/resources/resources_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_api.dart';

class LocaleContainer {
  final Locale locale;

  LocaleContainer(this.locale);
}

@module
class AppDiModule {
  Locale _locale;
  final BaseCookiesProvider _cookiesProvider = CookiesProvider();
  final BasePassphraseProvider _passphraseProvider = PassphraseProvider();
  final BaseSecureStorageProvider _secureStorageProvider =
      SecureStorageProvider();
  final BaseThemeDataProvider _themeDataProvider = ThemeDataProvider();
  final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics();
  final BaseSettingsProvider _settingsProvider = SettingsProvider();
  final BaseAutofillHintsProvider _autofillHintsProvider =
      AutofillHintsProvider();
  BaseUsersProvider _usersProvider;
  BaseGroupsProvider _groupsProvider;
  BasePermissionsProvider _permissionsProvider;

  AppDiModule(Locale currentLocale) {
    this._locale = currentLocale;
  }

  @provide
  @singleton
  LocaleContainer provideLocale() => LocaleContainer(this._locale);

  @provide
  http.BaseHttpClientProvider httpClientProvider() => http.HttpClientProvider();

  @provide
  BasePermissionsApi permissionsApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      PermissionsApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  BaseGroupsApi groupsApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      GroupsApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  BaseGpgKeysApi gpgKeysApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      GpgKeysApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  BaseUsersApi usersApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      UsersApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  BaseSharingApi sharingApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      SharingApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  BaseCommentsApi commentsApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      CommentsApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  @singleton
  BaseResourcesApi resourcesApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      ResourcesApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  @singleton
  BaseSecretApi secretApi(
    http.BaseHttpClientProvider httpClientProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseCookiesProvider cookiesProvider,
    Connectivity connectivity,
  ) =>
      SecretApi(
        httpClientProvider,
        secureStorageProvider,
        cookiesProvider,
        connectivity,
      );

  @provide
  @singleton
  BaseCookiesProvider cookiesProvider() => _cookiesProvider;

  @provide
  @singleton
  BasePassphraseProvider passphraseProvider() => _passphraseProvider;

  @provide
  @singleton
  BaseSecureStorageProvider secureStorageProvider() => _secureStorageProvider;

  @provide
  @singleton
  BaseThemeDataProvider themeDataProvider() => _themeDataProvider;

  @provide
  @singleton
  BaseSettingsProvider settingsProvider() => _settingsProvider;

  @provide
  @singleton
  FirebaseAnalytics firebaseAnalytics() => _firebaseAnalytics;

  @provide
  @singleton
  BaseUsersProvider usersProvider(BaseUsersApi usersApi) {
    if (_usersProvider == null) {
      _usersProvider = UsersProvider(usersApi);
    }

    return _usersProvider;
  }

  @provide
  @singleton
  BaseGroupsProvider groupsProvider(BaseGroupsApi groupsApi) {
    if (_groupsProvider == null) {
      _groupsProvider = GroupsProvider(groupsApi);
    }

    return _groupsProvider;
  }

  @provide
  @singleton
  BasePermissionsProvider permissionsProvider(
    BasePermissionsApi permissionsApi,
    BaseUsersProvider usersProvider,
    BaseGroupsProvider groupsProvider,
  ) {
    if (_permissionsProvider == null) {
      _permissionsProvider =
          PermissionsProvider(permissionsApi, usersProvider, groupsProvider);
    }

    return _permissionsProvider;
  }

  @provide
  @singleton
  Connectivity connectivityProvider() {
    return Connectivity();
  }

  @provide
  @singleton
  BaseAutofillHintsProvider autofillHintsProvider() => _autofillHintsProvider;

  @provide
  @singleton
  BaseAutofillValuesProvider autofillValuesProvider(
    BaseSecretApi secretApi,
    BaseResourcesApi resourcesApi,
    BaseSecureStorageProvider secureStorageProvider,
    BasePassphraseProvider passphraseProvider,
  ) {
    return AutofillValuesProvider(
      secretApi,
      resourcesApi,
      secureStorageProvider,
      passphraseProvider,
    );
  }
}
