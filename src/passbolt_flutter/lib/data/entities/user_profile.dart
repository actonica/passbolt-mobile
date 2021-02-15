// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/entities/passbolt_user_profile.dart';

class UserProfile {
  static bool isDefaultAvatar(String avatarUrl) =>
      avatarUrl == null ||
      avatarUrl.contains('user_medium.png') ||
      avatarUrl.contains('group_default.png');

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String avatarUrl;

  UserProfile(
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  );

  factory UserProfile.from(PassboltUserProfile model, String baseUrl) =>
      UserProfile(
        model.id,
        model.user_id,
        model.first_name,
        model.last_name,
        '$baseUrl/${model.avatar.url.medium}',
      );

  @override
  String toString() {
    return 'UserProfile{id: $id, userId: $userId, firstName: $firstName, lastName: $lastName, avatarUrl: $avatarUrl}';
  }
}
