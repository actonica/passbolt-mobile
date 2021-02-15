// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:autofill/autofill.dart';
import 'package:logging/logging.dart';
import 'package:openpgp/openpgp.dart';
import 'package:passbolt_flutter/common/decrypt.dart';
import 'package:passbolt_flutter/common/interactor.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/providers/autofill_hints_provider.dart';
import 'package:passbolt_flutter/data/providers/autofill_values_provider.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/modules/resources/resources_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_api.dart';

class GetAutofillValuesOrResourcesResponse {
  final List<Resource> resources;

  GetAutofillValuesOrResourcesResponse(this.resources);
}

class SelectResourceForAutofillRequest {
  final Resource resource;

  SelectResourceForAutofillRequest(this.resource);
}

abstract class BaseAutofillValuesInteractor implements Interactor {
  Future<GetAutofillValuesOrResourcesResponse> getAutofillValuesOrResources();

  Future<void> selectResourceForAutofill(
      SelectResourceForAutofillRequest request);
}

class AutofillValuesInteractor implements BaseAutofillValuesInteractor {
  final Logger _logger = Logger('AutofillValuesInteractor');
  final BaseAutofillHintsProvider _autofillHintsProvider;
  final BaseSecretApi _secretApi;
  final BaseResourcesApi _resourcesApi;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BasePassphraseProvider _passphraseProvider;
  final List<String> _badWords = ['android', 'ios'];

  AutofillValuesInteractor(
    this._autofillHintsProvider,
    this._secretApi,
    this._resourcesApi,
    this._secureStorageProvider,
    this._passphraseProvider,
  );

  @override
  Future<void> selectResourceForAutofill(
      SelectResourceForAutofillRequest request) async {
    final datasets = await _buildAutofillDatasets(<Resource>[request.resource]);
    await Autofill.setAutofillValues(AutofillValues(datasets).toMap());
  }

  @override
  Future<GetAutofillValuesOrResourcesResponse>
      getAutofillValuesOrResources() async {
    final autofillHints = _autofillHintsProvider.autofillHints;
    final packageId = autofillHints.autofillIdPackage;
    final webDomain = autofillHints.autofillWebDomain;
    _logger.fine(
        'buildAutofillValues webDomain ${webDomain} packageId ${packageId}');

    final resourcesResponse =
        await _resourcesApi.getResources(GetResourcesRequest());

    List<Resource> resources = [];

    try {
      if (webDomain != null) {
        _logger.fine('buildAutofillValues webDomain ${webDomain}');
        resources = _findResourcesByWebDomain(
          resourcesResponse.resources,
          webDomain,
        );
      } else if (packageId != null) {
        _logger.fine('buildAutofillValues packageId ${packageId}');
        resources = _findResourcesByPackageId(
          resourcesResponse.resources,
          packageId,
        );
      } else {
        resources = [];
      }
    } catch (error) {
      _logger.warning(error.toString());
    }

    _logger.fine('buildAutofillValues resources ${resources}');

    if (resources.isNotEmpty && resources.length < 3) {
      final datasets = await _buildAutofillDatasets(resources);
      await Autofill.setAutofillValues(AutofillValues(datasets).toMap());
      return GetAutofillValuesOrResourcesResponse(null);
    } else {
      return GetAutofillValuesOrResourcesResponse(resourcesResponse.resources);
    }
  }

  Future<List<AutofillDataset>> _buildAutofillDatasets(
      List<Resource> resources) async {
    final autofillHints = _autofillHintsProvider.autofillHints;
    AutofillHint userNameHint;
    AutofillHint passwordHint;

    autofillHints.hints.forEach(
      (AutofillHint autofillHint) {
        _logger.fine('autofillHint: $autofillHint');

        if (autofillHint.hint.contains("username") ||
            autofillHint.hint.contains("name") ||
            autofillHint.hint.contains("emailaddress")) {
          userNameHint = autofillHint;
        } else if (autofillHint.hint.contains("password")) {
          passwordHint = autofillHint;
        }
      },
    );

    _logger.fine('userNameHint: $userNameHint, passwordHint: $passwordHint');

    List<AutofillDataset> datasets = [];
    await Future.forEach(
      resources,
      (Resource resource) async {
        final values = List<AutofillValue>();

        if (userNameHint != null) {
          values.add(
            AutofillValue(
              userNameHint.hint,
              userNameHint.autofillId,
              resource.username,
              resource.name,
            ),
          );
        }

        if (passwordHint != null) {
          final secretResponse =
              await _secretApi.getSecret(GetSecretRequest(resource.id));

          final clear = await decryptOpenPgpJsMessage(
              secretResponse.secret.encryptedData,
              await _secureStorageProvider
                  .getProperty(SecureStorageKey.PRIVATE_KEY_ASC),
              _passphraseProvider.passphrase);

          values.add(
            AutofillValue(
              passwordHint.hint,
              passwordHint.autofillId,
              clear,
              resource.name,
            ),
          );
        }

        final autofillDataset = AutofillDataset(values);
        _logger.fine('autofillDataset: $autofillDataset');
        datasets.add(autofillDataset);
      },
    );

    return datasets;
  }

  List<Resource> _findResourcesByWebDomain(
    List<Resource> allResources,
    String webDomain,
  ) {
    return _findResourcesByString(allResources, webDomain);
  }

  List<Resource> _findResourcesByPackageId(
    List<Resource> allResources,
    String packageId,
  ) {
    final packageIdParts = packageId.split(".");

    if (packageIdParts.length > 2) {
      return _findResourcesByString(allResources, packageIdParts[1]);
    } else {
      return _findResourcesByString(allResources, packageId);
    }
  }

  List<Resource> _findResourcesByString(
    List<Resource> allResources,
    String string,
  ) {
    if (_badWords.any((badWord) {
      return badWord == string;
    })) {
      return [];
    }

    return allResources.where(
      (resource) {
        return _isResourceContains(resource, string);
      },
    ).toList();
  }

  bool _isResourceContains(Resource resource, String string) {
    return (resource.uri?.toLowerCase()?.contains(string) ?? false) ||
        (resource.username?.toLowerCase()?.contains(string) ?? false) ||
        resource.name.toLowerCase().contains(string);
  }
}
