// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

abstract class ValuesConverter {
  static final _logger = Logger('ValuesConverter');

  static String nullOrEmptyToNa(String value) {
    if (value == null || value.isEmpty) {
      return 'n/a';
    } else {
      return value;
    }
  }

  static String toTimeFromNow(String value) {
    try {
      final time = DateTime.parse(value);
      final now = DateTime.now();
      final diff = now.difference(time);

      if (diff.inSeconds < 60) {
        return 'few seconds ago';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} minutes ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hours ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        final formatter = DateFormat('dd.MM.yyyy');
        return formatter.format(time);
      }
    } catch (error) {
      _logger.warning(error.toString());
      return null;
    }
  }

  static DateTime toDateTime(String value) {
    try {
      return DateTime.parse(value);
    } catch (error) {
      _logger.warning(error.toString());
      return null;
    }
  }
}
