// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:json_annotation/json_annotation.dart';

part 'passbolt_comment.g.dart';

// https://help.passbolt.com/api/comments

@JsonSerializable()
class PassboltComment {
  final String content;
  final String created;
  final String user_id;

  PassboltComment(this.user_id, this.content, this.created);

  factory PassboltComment.fromJson(Map<String, dynamic> json) =>
      _$PassboltCommentFromJson(json);
}
