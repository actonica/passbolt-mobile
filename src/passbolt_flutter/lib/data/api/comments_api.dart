// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/server_api.dart';
import 'package:passbolt_flutter/data/entities/passbolt_comment.dart';
import 'package:passbolt_flutter/data/providers/cookies_provider.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';

class GetCommentsRequest {
  final String resourceId;

  GetCommentsRequest(this.resourceId);
}

class GetWsCommentsResponse {
  final List<PassboltComment> comments;

  GetWsCommentsResponse(this.comments);
}

abstract class BaseCommentsApi {
  Future<GetWsCommentsResponse> getComments(GetCommentsRequest request);
}

class CommentsApi extends ServerApi implements BaseCommentsApi {
  final BaseHttpClientProvider _httpClientProvider;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BaseCookiesProvider _cookiesProvider;
  final _logger = Logger("CommentsApi");

  CommentsApi(
    this._httpClientProvider,
    this._secureStorageProvider,
    this._cookiesProvider,
    Connectivity connectivity,
  ) : super(connectivity);

  @override
  Future<GetWsCommentsResponse> getComments(GetCommentsRequest request) {
    return execute(
      () async {
        final baseUrl = await _secureStorageProvider.getProperty(
          SecureStorageKey.BASE_URL,
        );
        final url =
            '$baseUrl/comments/resource/${request.resourceId}.json?api-version=v2';

        final client = _httpClientProvider.getHttpClient();
        client.options.headers['cookie'] = _cookiesProvider.cakePhp;

        final wsResponse = await client.get(url);
        printResponse(wsResponse);

        final List<dynamic> json = wsResponse.data['body'];

        final comments = json.map((item) {
          final groupJson = item as Map<String, dynamic>;
          final passboltComment = PassboltComment.fromJson(groupJson);
          return passboltComment;
        }).toList();

        return GetWsCommentsResponse(comments);
      },
    );
  }
}
