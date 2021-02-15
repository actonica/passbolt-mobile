// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:passbolt_flutter/data/api/sharing_api.dart';
import 'package:passbolt_flutter/data/entities/permission.dart';

class AroPermission {
  final Permission permission;
  final Aro aro;

  AroPermission(this.permission, this.aro);
}
