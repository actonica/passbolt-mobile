// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';
import 'package:passbolt_flutter/data/entities/passbolt_avatar.dart';

part 'passbolt_user_profile.g.dart';

@JsonSerializable()
class PassboltUserProfile {
  final String id;
  final String user_id;
  final String first_name;
  final String last_name;
  final String created;
  final String modified;
  final PassboltAvatar avatar;

  PassboltUserProfile(
    this.id,
    this.user_id,
    this.first_name,
    this.last_name,
    this.created,
    this.modified,
    this.avatar,
  );

  factory PassboltUserProfile.fromJson(Map<String, dynamic> json) =>
      _$PassboltUserProfileFromJson(json);
}
