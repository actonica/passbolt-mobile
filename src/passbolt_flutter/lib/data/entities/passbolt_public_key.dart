// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';

part 'passbolt_public_key.g.dart';

@JsonSerializable()
class PassboltPublicKey {
  final String id;
  @JsonKey(name: "key_id")
  final String keyId;
  final String uid;
  final String user_id;
  @JsonKey(name: "armored_key")
  final String armoredKey;
  final String created;
  @JsonKey(name: "key_created")
  final String keyCreated;
  final int bits;
  final bool deleted;
  final String fingerprint;
  final String type;
  final String expires;

  PassboltPublicKey(
    this.id,
    this.keyId,
    this.uid,
    this.user_id,
    this.armoredKey,
    this.created,
    this.keyCreated,
    this.bits,
    this.deleted,
    this.fingerprint,
    this.type,
    this.expires,
  );

  factory PassboltPublicKey.fromJson(Map<String, dynamic> json) =>
      _$PassboltPublicKeyFromJson(json);

  @override
  String toString() {
    return 'PassboltPublicKey{id: $id, keyId: $keyId, uid: $uid, user_id: $user_id, armoredKey: $armoredKey, created: $created, keyCreated: $keyCreated, bits: $bits, deleted: $deleted, fingerprint: $fingerprint, type: $type, expires: $expires}';
  }
}
