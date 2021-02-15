// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';
import 'package:passbolt_flutter/data/entities/passbolt_user.dart';

part 'passbolt_group_user.g.dart';

@JsonSerializable()
class PassboltGroupUser {
  final String id;

  PassboltGroupUser(this.id);

  factory PassboltGroupUser.fromJson(Map<String, dynamic> json) =>
      _$PassboltGroupUserFromJson(json);
}
