// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:encrypt/encrypt.dart';

abstract class BasePassphraseProvider {
  String passphrase;
}

class PassphraseProvider implements BasePassphraseProvider {
  Encrypted _encrypted;
  Encrypter _encrypter;
  IV _iv = IV.fromLength(16);

  PassphraseProvider() {
    Key key = Key.fromSecureRandom(32);
    _encrypter = Encrypter(AES(key));
  }

  @override
  String get passphrase {
    return _encrypter.decrypt(_encrypted, iv: _iv);
  }

  @override
  set passphrase(String _passphrase) {
    _encrypted = _encrypter.encrypt(_passphrase, iv: _iv);
  }
}
