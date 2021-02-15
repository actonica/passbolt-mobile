// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

abstract class BaseImportKeyInteractor implements Interactor {
  void setPrivateKey(String privateKey);
}

class ImportKeyInteractor implements BaseImportKeyInteractor {
  final BaseSecureStorageProvider _secureStorageProvider;
  final _logger = Logger("ImportKeyInteractor");

  ImportKeyInteractor(this._secureStorageProvider);

  @override
  void setPrivateKey(String privateKey) {
    _secureStorageProvider.setProperty(
      SecureStorageKey.TEMP_PRIVATE_KEY_ASC,
      privateKey,
    );
  }
}
