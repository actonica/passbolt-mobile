import 'dart:async';

import 'package:biometrics_vault/biometrics_vault.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _accessGroupId = "someAccessGroupId";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String message;
    final key = 'someSecretKey2';

    try {
      await Future.delayed(Duration(seconds: 1));
      String decodedSecret = await BiometricsVault.getSecretWithBiometrics(
        instructions: 'someGetInstructions',
        key: key,
        accessGroupId: _accessGroupId,
      );

      if (decodedSecret != null) {
        final result = await BiometricsVault.deleteSecretWithBiometrics(
            instructions: 'delete', key: key,
          accessGroupId: _accessGroupId,);
        message = result;
      } else {
        final result = await BiometricsVault.setSecretWithBiometrics(
            instructions: 'someSetInstructions', key: key, clear: 'helloworld',
          accessGroupId: _accessGroupId,);
        message = 'set secret result: $result';
      }
    } catch (error) {
      message = '${error.toString()} Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
