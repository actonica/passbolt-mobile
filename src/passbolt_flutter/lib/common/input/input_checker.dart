// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';

abstract class InputChecker {
  static final _urlPattern =
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
  static final _invalidUrlCharsPattern = r"[^A-Z0-9+&@#/%=~_|!:,.;]";
  static final _invalidFingerprintCharsPattern = r"[^A-F0-9]";
  static final _logger = Logger('InputChecker');

  static bool isFingerprintValid(String fingerprint) {
    final invalidMatch = RegExp(
      _invalidFingerprintCharsPattern,
      caseSensitive: false,
    ).firstMatch(fingerprint);

    return invalidMatch == null;
  }

  static String checkAndTryRepairFingerprint(String fingerprint) {
    if (!isFingerprintValid(fingerprint)) {
      _logger
          .info("fingerprint $fingerprint is invalid, I can try to repair it");

      final repairedFingerprint = _tryRepairFingerprint(fingerprint);
      _logger.info("repaired fingerprint $repairedFingerprint");
      return repairedFingerprint;
    }

    return fingerprint;
  }

  static bool isUrlValid(String url) {
    final invalidMatch = RegExp(
      _invalidUrlCharsPattern,
      caseSensitive: false,
    ).firstMatch(url);

    final validMatch = RegExp(
      _urlPattern,
      caseSensitive: false,
    ).firstMatch(url);
    return invalidMatch == null && validMatch != null;
  }

  static String checkAndTryRepairUrl(String url) {
    if (!isUrlValid(url)) {
      _logger.info("url $url is invalid, I can try to repair it");

      final repairedUrl = _tryRepairUrl(url);
      _logger.info("repaired url $repairedUrl");
      return repairedUrl;
    }

    return url;
  }

  static String _tryRepairFingerprint(String fingerprint) {
    String repairedFingerprint = fingerprint.trim();
    return repairedFingerprint;
  }

  static String _tryRepairUrl(String url) {
    String repairedUrl = url.trim();

    if (!repairedUrl.contains('https://') && !repairedUrl.contains('http://')) {
      return 'https://$repairedUrl';
    }

    return repairedUrl;
  }
}
