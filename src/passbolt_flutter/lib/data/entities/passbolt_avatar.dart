// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';
import 'package:passbolt_flutter/data/entities/passbolt_url.dart';

part 'passbolt_avatar.g.dart';

@JsonSerializable()
class PassboltAvatar {
  final PassboltUrl url;

  PassboltAvatar(this.url);

  factory PassboltAvatar.fromJson(Map<String, dynamic> json) =>
      _$PassboltAvatarFromJson(json);
}
