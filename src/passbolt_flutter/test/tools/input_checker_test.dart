import 'package:flutter_test/flutter_test.dart';
import 'package:passbolt_flutter/common/input/input_checker.dart';

void main() {
  group(
    'input_checker_fingerprint',
    () {
      test(
        'good_fingerprint_is_valid',
        () {
          final goodFingerprint = 'FF01FD';
          final isValidResult =
              InputChecker.isFingerprintValid(goodFingerprint);
          expect(isValidResult, true);
        },
      );

      test(
        'bad_fingerprint_is_invalid',
        () {
          final badFingerprint = 'GGGGGG';
          final isValidResult = InputChecker.isFingerprintValid(badFingerprint);
          expect(isValidResult, false);
        },
      );

      test(
        'check_and_try_repair_repairable_fingerprint_return_valid_fingerprint',
        () {
          final badFingerprints = [' FFFFF '];

          badFingerprints.forEach(
            (badFingerprint) {
              final goodFingerprint =
                  InputChecker.checkAndTryRepairFingerprint(badFingerprint);
              final isValidResult =
                  InputChecker.isFingerprintValid(goodFingerprint);
              expect(isValidResult, true);
            },
          );
        },
      );

      test(
        'check_and_try_repair_not_repairable_fingerprint_return_invalid_fingerprint',
        () {
          final badFingerprints = ['FF FF'];

          badFingerprints.forEach(
            (badFingerprint) {
              final goodFingerprint =
                  InputChecker.checkAndTryRepairFingerprint(badFingerprint);
              final isValidResult =
                  InputChecker.isFingerprintValid(goodFingerprint);
              expect(isValidResult, false);
            },
          );
        },
      );
    },
  );

  group(
    'input_checker_url',
    () {
      test(
        'good_url_is_valid',
        () {
          final goodUrl = 'https://someurl.com';
          final isValidResult = InputChecker.isUrlValid(goodUrl);
          expect(isValidResult, true);
        },
      );

      test(
        'bad_url_is_invalid',
        () {
          final badUrl = 'someurl.com';
          final isValidResult = InputChecker.isUrlValid(badUrl);
          expect(isValidResult, false);
        },
      );

      test(
        'check_and_try_repair_repairable_url_return_valid_url',
        () {
          final badUrls = ['someurl.com', ' someurl.com '];

          badUrls.forEach(
            (badUrl) {
              final goodUrl = InputChecker.checkAndTryRepairUrl(badUrl);
              final isValidResult = InputChecker.isUrlValid(goodUrl);
              expect(isValidResult, true);
            },
          );
        },
      );

      test(
        'check_and_try_repair_not_repairable_url_return_invalid_url',
        () {
          final badUrls = ['some url.com'];

          badUrls.forEach(
            (badUrl) {
              final goodUrl = InputChecker.checkAndTryRepairUrl(badUrl);
              final isValidResult = InputChecker.isUrlValid(goodUrl);
              expect(isValidResult, false);
            },
          );
        },
      );
    },
  );
}
