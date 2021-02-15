// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:inject/inject.dart';
import 'package:passbolt_flutter/data/providers/autofill_hints_provider.dart';
import 'package:passbolt_flutter/data/providers/passphrase_provider.dart';
import 'package:passbolt_flutter/data/providers/secure_storage_provider.dart';
import 'package:passbolt_flutter/modules/autofill_values/autofill_values_bloc.dart';
import 'package:passbolt_flutter/modules/autofill_values/autofill_values_interactor.dart';
import 'package:passbolt_flutter/modules/resources/resources_api.dart';
import 'package:passbolt_flutter/modules/secret/secret_api.dart';

@module
class AutofillValuesDiModule {
  @provide
  @singleton
  BaseAutofillValuesInteractor interactor(
    BaseAutofillHintsProvider autofillHintsProvider,
    BaseSecretApi secretApi,
    BaseResourcesApi resourcesApi,
    BaseSecureStorageProvider secureStorageProvider,
    BasePassphraseProvider passphraseProvider,
  ) =>
      AutofillValuesInteractor(
        autofillHintsProvider,
        secretApi,
        resourcesApi,
        secureStorageProvider,
        passphraseProvider,
      );

  @provide
  @singleton
  BaseAutofillValuesBloc bloc(BaseAutofillValuesInteractor interactor) =>
      AutofillValuesBloc(interactor);
}
