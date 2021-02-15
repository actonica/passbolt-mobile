import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autofill/autofill.dart';

void main() {
  const MethodChannel channel = MethodChannel('autofill');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Autofill.platformVersion, '42');
  });
}
