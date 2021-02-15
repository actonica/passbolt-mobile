import 'package:flutter/material.dart';

Widget prepareWidgetForTesting(Widget child) {
  return MaterialApp(
    home: child,
  );
}