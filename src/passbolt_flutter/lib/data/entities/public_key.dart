// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';
import 'package:passbolt_flutter/data/entities/passbolt_public_key.dart';

class PublicKey {
  final String id;
  final String uid;
  final String userId;
  final String armoredKey;
  final String created;
  final int bits;
  final String fingerprint;
  final String type;
  final String expires;

  PublicKey({
    @required this.id,
    @required this.uid,
    @required this.userId,
    @required this.armoredKey,
    @required this.created,
    @required this.bits,
    @required this.fingerprint,
    @required this.type,
    @required this.expires,
  });

  factory PublicKey.from(PassboltPublicKey key) => PublicKey(
        id: key.keyId,
        uid: key.uid,
        userId: key.user_id,
        armoredKey: key.armoredKey,
        created: key.keyCreated,
        bits: key.bits,
        fingerprint: key.fingerprint,
        type: key.type,
        expires: key.expires,
      );

  @override
  String toString() {
    return 'PublicKey{id: $id, uid: $uid, userId: $userId, armoredKey: $armoredKey, created: $created, bits: $bits, fingerprint: $fingerprint, type: $type, expires: $expires}';
  }
}
