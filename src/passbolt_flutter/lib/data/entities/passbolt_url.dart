// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';

part 'passbolt_url.g.dart';

@JsonSerializable()
class PassboltUrl {
  final String small;
  final String medium;

  PassboltUrl(this.small, this.medium);

  factory PassboltUrl.fromJson(Map<String, dynamic> json) =>
      _$PassboltUrlFromJson(json);
}
