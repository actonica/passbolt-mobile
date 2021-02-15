// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/entities/passbolt_group.dart';
import 'package:passbolt_flutter/data/entities/passbolt_group_user.dart';

class Group {
  final String id;
  final String name;
  final List<String> users;
  final String avatarUrl;

  Group(this.id, this.name, this.users, this.avatarUrl);

  factory Group.from(PassboltGroup group, String baseUrl) {
    final users = group.users?.map(
      (PassboltGroupUser passboltGroupUser) {
        return passboltGroupUser.id;
      },
    )?.toList();

    return Group(
      group.id,
      group.name,
      users,
      '${baseUrl}/img/avatar/group_default.png',
    );
  }
}
