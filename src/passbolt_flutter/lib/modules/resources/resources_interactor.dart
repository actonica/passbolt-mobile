// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:io';

import 'package:autofill/autofill.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/providers/groups_provider.dart';
import 'package:passbolt_flutter/modules/resources/resources_api.dart';

abstract class BaseResourcesInteractor implements Interactor {
  Future<GetResourcesResponse> getResources(GetResourcesRequest request);
}

class ResourcesInteractor implements BaseResourcesInteractor {
  final BaseResourcesApi _api;
  final BaseGroupsProvider _baseGroupsProvider;
  final _logger = Logger("ResourcesInteractor");

  ResourcesInteractor(this._api, this._baseGroupsProvider);

  @override
  Future<GetResourcesResponse> getResources(GetResourcesRequest request) async {
    final wsResponse = await _api.getResources(request);

    if (Platform.isIOS) {
      _logger.fine('removeAllCredentials');
      await Autofill.removeAllCredentials();
      _logger.fine('addCredentials');
      await Autofill.addCredentials(
        wsResponse.resources.map(
          (Resource resource) {
            return AutofillCredential(
              resource.uri != null && resource.uri.isNotEmpty
                  ? resource.uri
                  : null,
              resource.username != null && resource.username.isNotEmpty
                  ? resource.username
                  : null,
              resource.id
            );
          },
        ).where(
          (AutofillCredential autofillCredential) {
            return autofillCredential.serviceIdentifier != null &&
                autofillCredential.userName != null;
          },
        ).toList(),
      );
    }

    await _baseGroupsProvider.getAllGroups();

    return wsResponse;
  }
}
