// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:convert';
import 'dart:math';

abstract class RandomPassword {
  static String create([int length = 12]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
