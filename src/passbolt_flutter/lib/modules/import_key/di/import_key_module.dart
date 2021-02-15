// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/modules/import_key/import_key_bloc.dart';
import 'package:passbolt_flutter/modules/import_key/import_key_interactor.dart';

@module
class ImportKeyDiModule {
  @provide
  @singleton
  BaseImportKeyInteractor interactor(
          BaseSecureStorageProvider secureStorageProvider) =>
      ImportKeyInteractor(secureStorageProvider);

  @provide
  @singleton
  BaseImportKeyBloc bloc(BaseImportKeyInteractor interactor) =>
      ImportKeyBloc(interactor);
}
