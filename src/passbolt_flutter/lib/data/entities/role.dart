// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/entities/passbolt_role.dart';

class Role {
  final String name;

  Role(this.name);

  factory Role.from(PassboltRole passboltRole) => Role(passboltRole.name);

  @override
  String toString() {
    return 'Role{name: $name}';
  }
}
