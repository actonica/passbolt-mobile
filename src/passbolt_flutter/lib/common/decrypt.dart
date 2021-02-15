import 'package:openpgp/openpgp.dart';

Future<String> decryptOpenPgpJsMessage(
    String message,
    String privateKey,
    String passphrase,
    ) async {
  final fixedMessage =
  message.replaceAll('BEGIN\\+PGP\\+MESSAGE', 'BEGIN PGP MESSAGE');
  return await OpenPGP.decrypt(fixedMessage, privateKey, passphrase);
}
