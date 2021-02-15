// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/entities/passbolt_user.dart';
import 'package:passbolt_flutter/data/entities/public_key.dart';
import 'package:passbolt_flutter/data/entities/role.dart';
import 'package:passbolt_flutter/data/entities/user_profile.dart';

class User {
  final String id;
  final String name;
  final PublicKey publicKey;
  final UserProfile profile;
  final Role role;

  User(this.id, this.name, this.publicKey, this.profile, this.role);

  factory User.from(PassboltUser user, String baseUrl) => User(
        user.id,
        user.username,
        PublicKey.from(user.gpgkey),
        UserProfile.from(user.profile, baseUrl),
        Role.from(user.role),
      );

  @override
  String toString() {
    return 'User{id: $id, name: $name, publicKey: $publicKey, profile: $profile, role: $role}';
  }
}
