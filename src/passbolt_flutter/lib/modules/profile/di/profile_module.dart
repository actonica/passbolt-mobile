// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/data/providers/users_provider.dart';
import 'package:passbolt_flutter/modules/profile/profile_bloc.dart';
import 'package:passbolt_flutter/modules/profile/profile_interactor.dart';

@module
class ProfileDiModule {
  @provide
  @singleton
  BaseProfileInteractor interactor(
    BaseUsersProvider usersProvider,
    BaseSecureStorageProvider secureStorageProvider,
    BaseSettingsProvider settingsProvider,
  ) =>
      ProfileInteractor(
        usersProvider,
        secureStorageProvider,
        settingsProvider,
      );

  @provide
  @singleton
  BaseProfileBloc bloc(BaseProfileInteractor interactor) =>
      ProfileBloc(interactor);
}
