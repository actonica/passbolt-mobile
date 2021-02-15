import 'package:flutter_test/flutter_test.dart';
import 'package:passbolt_flutter/data/providers/autofill_hints_provider.dart';

void main() {
  group(
    'autofill_hints',
    () {
      test(
        'autofill_hints_from_map',
        () {
          final Map<dynamic, dynamic> map = {};
          map["autofillWebDomain"] = "some web domain";
          map["autofillIdPackage"] = "some package id";

          final List<dynamic> hints = [];
          hints.add({'hint':'username', 'autofillId':'1073741824:true:5'});
          hints.add({'hint':'password', 'autofillId':'1073741824:true:6'});
          map["hints"] = hints;

          final dataset = AutofillHints.from(map);

          expect(dataset.autofillIdPackage, 'some package id');
        },
      );
    },
  );
}
