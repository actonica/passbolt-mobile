// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';
import 'package:passbolt_flutter/data/entities/passbolt_public_key.dart';
import 'package:passbolt_flutter/data/entities/passbolt_role.dart';
import 'package:passbolt_flutter/data/entities/passbolt_user_profile.dart';

part 'passbolt_user.g.dart';

@JsonSerializable()
class PassboltUser {
  final String id;
  final String username;
  final PassboltUserProfile profile;
  final PassboltRole role;
  final PassboltPublicKey gpgkey;

  PassboltUser(this.id, this.username, this.profile, this.role, this.gpgkey);

  factory PassboltUser.fromJson(Map<String, dynamic> json) =>
      _$PassboltUserFromJson(json);
}