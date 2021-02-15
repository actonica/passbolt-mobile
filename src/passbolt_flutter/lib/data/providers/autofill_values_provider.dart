// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:openpgp/openpgp.dart';
import 'package:passbolt_flutter/common/decrypt.dart';
import 'package:passbolt_flutter/data/entities/resource.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/modules/resources/resources_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_api.dart';

import 'autofill_hints_provider.dart';

class AutofillValues {
  final List<AutofillDataset> datasets;

  AutofillValues(this.datasets);

  Map<dynamic, dynamic> toMap() {
    Map<dynamic, dynamic> result = {};

    List<Map<dynamic, dynamic>> datasetsList = [];

    datasets.forEach(
      (AutofillDataset dataset) {
        Map<dynamic, dynamic> datasetMap = {};
        List<Map<dynamic, dynamic>> valuesList = [];

        dataset.values.forEach(
          (AutofillValue autofillValue) {
            Map<dynamic, dynamic> hintMap = {};
            hintMap["hint"] = autofillValue.hint;
            hintMap["autofillId"] = autofillValue.autofillId;
            hintMap["valueForHint"] = autofillValue.valueForHint;
            hintMap["labelForHint"] = autofillValue.labelForHint;
            valuesList.add(hintMap);
          },
        );

        datasetMap["values"] = valuesList;
        datasetsList.add(datasetMap);
      },
    );
    result["datasets"] = datasetsList;
    return result;
  }
}

class AutofillDataset {
  final List<AutofillValue> values;

  AutofillDataset(this.values);

  @override
  String toString() {
    return 'AutofillDataset{values: ${values.join(', ')}}';
  }
}

class AutofillValue {
  final String hint;
  final String autofillId;
  final String valueForHint;
  final String labelForHint;

  AutofillValue(
    this.hint,
    this.autofillId,
    this.valueForHint,
    this.labelForHint,
  );

  @override
  String toString() {
    return 'AutofillValue{hint: $hint, autofillId: $autofillId,'
        ' valueForHint: $valueForHint, labelForHint: $labelForHint}';
  }
}

abstract class BaseAutofillValuesProvider {
  Future<AutofillValues> buildAutofillValues(AutofillHints autofillHints);
}

class AutofillValuesProvider implements BaseAutofillValuesProvider {
  final Logger _logger = Logger('AutofillValuesProvider');
  final BaseSecretApi _secretApi;
  final BaseResourcesApi _resourcesApi;
  final BaseSecureStorageProvider _secureStorageProvider;
  final BasePassphraseProvider _passphraseProvider;
  final List<String> _badWords = ['android', 'ios'];

  AutofillValuesProvider(
    this._secretApi,
    this._resourcesApi,
    this._secureStorageProvider,
    this._passphraseProvider,
  );

  @override
  Future<AutofillValues> buildAutofillValues(
      AutofillHints autofillHints) async {
    _logger.fine('buildAutofillValues autofillHints: ${autofillHints}');

    final packageId = autofillHints.autofillIdPackage;
    final webDomain = autofillHints.autofillWebDomain;

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

    AutofillHint userNameHint;
    AutofillHint passwordHint;

    autofillHints.hints.forEach(
      (AutofillHint autofillHint) {
        if (autofillHint.hint.contains("username") ||
            autofillHint.hint.contains("emailAddress")) {
          userNameHint = autofillHint;
        } else if (autofillHint.hint.contains("password")) {
          passwordHint = autofillHint;
        }
      },
    );

    List<AutofillDataset> datasets = [];

    if (resources.isEmpty) {
      final values = List<AutofillValue>();

      autofillHints.hints.forEach(
        (AutofillHint autofillHint) {
          values.add(
            AutofillValue(
              autofillHint.hint,
              autofillHint.autofillId,
              'Passbolt was unable to fill this app',
              '',
            ),
          );
        },
      );

      datasets.add(AutofillDataset(values));
    } else {
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

          datasets.add(AutofillDataset(values));
        },
      );
    }

    return AutofillValues(datasets);
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
    if (_badWords.any((badWord) {return badWord == string;})) {
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
