// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/exceptions.dart';

class ServerApi {
  Logger _logger;
  final Connectivity _connectivity;

  ServerApi(this._connectivity);

  @protected
  Logger get logger {
    if (_logger == null) {
      _logger = Logger(this.runtimeType.toString());
    }
    return _logger;
  }

  Future<T> execute<T>(Future<T> Function() action) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult != ConnectivityResult.none) {
        return await action();
      } else {
        throw NoInternetException('Error. Check your Internet connection, please.');
      }
    } catch (error) {
      if (error is DioError) {
        String message;
        switch (error.type) {
          case DioErrorType.CANCEL:
            message = 'Request was canceled';
            break;
          case DioErrorType.CONNECT_TIMEOUT:
            message = 'Connection timeout';
            break;
          case DioErrorType.RECEIVE_TIMEOUT:
            message = 'Receive timeout';
            break;
          case DioErrorType.RESPONSE:
            message =
                'Response error, status code ${error.response?.statusCode}';
            if (error.response?.statusCode == 403) {
              throw UnauthorizedException(message);
            }
            break;
          case DioErrorType.SEND_TIMEOUT:
            message = 'Send timeout';
            break;
          default:
            message = error.message;
            break;
        }
        throw HttpClientException(message);
      } else {
        throw ServerApiException(error.toString());
      }
    }
  }

  void printResponse(Response wsResponse) {
    printResponseWithoutBody(wsResponse);
    logger.fine('http response ${wsResponse.data}');
  }

  void printResponseWithoutBody(Response wsResponse) {
    logger.fine('http response headers ${wsResponse.headers}');
    logger.fine('http response statusCode ${wsResponse.statusCode}');
    logger.fine('http response statusMessage ${wsResponse.statusMessage}');
  }
}
