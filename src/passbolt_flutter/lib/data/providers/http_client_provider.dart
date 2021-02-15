// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:dio/dio.dart';
import 'package:passbolt_flutter/app/app_assembly.dart';

abstract class BaseHttpClientProvider {
  Dio getHttpClient();
}

class HttpClientProvider implements BaseHttpClientProvider {
  @override
  Dio getHttpClient() {
    return Dio(
      BaseOptions(
        connectTimeout: AppAssembly.httpConnectTimeout,
        sendTimeout: AppAssembly.httpSendTimeout,
        receiveTimeout: AppAssembly.httpReceiveTimeout,
      ),
    );
  }
}
