// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SecureStorageKey {
  BASE_URL,
  PUBLIC_KEY_FINGERPRINT,
  TEMP_PRIVATE_KEY_ASC,
  PRIVATE_KEY_ASC,
  USER_NAME,
  ALIAS_FOR_PASSPHRASE_KEY
}

abstract class BaseSecureStorageProvider {
  Future<String> getProperty(SecureStorageKey key);

  Future<void> setProperty(SecureStorageKey key, String value);

  Future<void> deleteProperty(SecureStorageKey key);

  Future<void> deleteAll();
}

class SecureStorageProvider implements BaseSecureStorageProvider {
  final _storage = FlutterSecureStorage();
  final _iOsOptions =
      iOSOptions(groupId: 'B5GS5KEWV8.com.actonica.pb.shareditems');

  @override
  Future<String> getProperty(SecureStorageKey key) async {
    return await _storage.read(key: key.toString(), iOptions: _iOsOptions);
  }

  @override
  Future<void> setProperty(SecureStorageKey key, String value) async {
    return await _storage.write(
        key: key.toString(), value: value, iOptions: _iOsOptions);
  }

  @override
  Future<void> deleteProperty(SecureStorageKey key) async {
    await _storage.delete(key: key.toString(), iOptions: _iOsOptions);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll(iOptions: _iOsOptions);
  }
}
