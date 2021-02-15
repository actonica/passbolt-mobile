// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:connectivity/connectivity.dart';
import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/http_client_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_api.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_bloc.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_interactor.dart';

@module
class VerifyServerDiModule {
  @provide
  @singleton
  BaseVerifyServerApi api(
    BaseHttpClientProvider httpClientProvider,
    Connectivity connectivity,
  ) =>
      VerifyServerApi(
        httpClientProvider,
        connectivity,
      );

  @provide
  @singleton
  BaseVerifyServerInteractor interactor(
    BaseVerifyServerApi api,
    BaseSecureStorageProvider secureStorageProvider,
  ) =>
      VerifyServerInteractor(api, secureStorageProvider);

  @provide
  @singleton
  BaseVerifyServerBloc bloc(BaseVerifyServerInteractor interactor) =>
      VerifyServerBloc(interactor);
}
