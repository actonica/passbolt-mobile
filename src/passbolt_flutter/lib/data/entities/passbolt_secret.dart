// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';

part 'passbolt_secret.g.dart';

@JsonSerializable()
class PassboltSecret {
  final String id;
  final String user_id;
  final String resource_id;
  final String data;
  final String created;
  final String modified;

  PassboltSecret(
    this.id,
    this.user_id,
    this.resource_id,
    this.data,
    this.created,
    this.modified,
  );

  factory PassboltSecret.fromJson(Map<String, dynamic> json) =>
      _$PassboltSecretFromJson(json);
}
