// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';

class AutofillHints {
  final String autofillIdPackage;
  final String autofillWebDomain;
  final List<AutofillHint> hints;

  AutofillHints(this.autofillIdPackage, this.autofillWebDomain, this.hints);

  factory AutofillHints.from(Map<dynamic, dynamic> map) {
    try {
      String autofillIdPackage = map["autofillIdPackage"];
      String autofillWebDomain = map["autofillWebDomain"];
      List<dynamic> hintMapList = map["hints"];
      List<AutofillHint> hints = [];

      hintMapList.forEach((hintMap) {
        AutofillHint autofillHint = AutofillHint(
          hintMap["hint"],
          hintMap["autofillId"],
        );
        hints.add(autofillHint);
      });

      return AutofillHints(autofillIdPackage, autofillWebDomain, hints);
    } catch (error) {
      Logger('AutofillDataset').warning('autofilldataset error $error');
      return null;
    }
  }

  @override
  String toString() {
    return 'AutofillDataset{autofillIdPackage: $autofillIdPackage, autofillWebDomain: $autofillWebDomain, hints: $hints}';
  }
}

class AutofillHint {
  final String hint;
  final String autofillId;

  AutofillHint(this.hint, this.autofillId);

  @override
  String toString() {
    return 'AutofillHint{hint: $hint, autofillId: $autofillId}';
  }
}

abstract class BaseAutofillHintsProvider {
  AutofillHints autofillHints;
}

class AutofillHintsProvider implements BaseAutofillHintsProvider {
  @override
  AutofillHints autofillHints;
}
