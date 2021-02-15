// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/entities/user.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';

abstract class BaseProfileInteractor implements Interactor {
  Future<User> getUser();

  Future<String> getPrivateKey();

  Future<Settings> getSettings();
}

class ProfileInteractor implements BaseProfileInteractor {
  final BaseUsersProvider _usersProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseSettingsProvider _settingsProvider;
  final _logger = Logger("ProfileInteractor");

  ProfileInteractor(
    this._usersProvider,
    this._secureStorageProvider,
    this._settingsProvider,
  );

  @override
  Future<User> getUser() async {
    return _usersProvider.getCurrentUser();
  }

  @override
  Future<String> getPrivateKey() {
    return _secureStorageProvider.getProperty(SecureStorageKey.PRIVATE_KEY_ASC);
  }

  @override
  Future<Settings> getSettings() {
    return _settingsProvider.getSettings();
  }
}
