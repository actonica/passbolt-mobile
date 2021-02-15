// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/material.dart';

abstract class AppColors {
  static final Color darkGradientEnd = Color(0xFF2C3E50);
  static final Color darkGradientStart = Color(0xFF415B75);
  static final Color main = Color(0xFF0088D4);
  static final Color searchIcon = Color(0xFF8E8E8E);
  static final Color searchBackground = Color(0xFFF4F4F4);
  static final Color error = Colors.redAccent;
}

abstract class BaseThemeDataProvider {
  ThemeData get lightThemeData;

  ThemeData get darkThemeData;
}

Widget createButton({String label, Color color, Function action, FocusNode focusNode}) {
  return ButtonTheme(
    buttonColor: color ?? AppColors.main,
    child: RaisedButton(
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        if (action != null) action();
      },
      elevation: 0,
      focusNode: focusNode,
    ),
  );
}

class ThemeDataProvider implements BaseThemeDataProvider {
  ThemeData _lightThemeData;
  ThemeData _darkThemeData;

  ThemeData get lightThemeData {
    if (_lightThemeData == null) {
      final _primary = Color(0xFFF2F2F2);
      final _secondary = Colors.black;
      final _disabled = Colors.grey;

      _lightThemeData = ThemeData(
        appBarTheme: AppBarTheme(
          color: AppColors.main,
          textTheme: Typography.englishLike2018,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: Typography.blackCupertino /*regular text*/,
        scaffoldBackgroundColor: Colors.white,
        highlightColor: Colors.black54,
        accentColor: _secondary,
        disabledColor: _disabled,
        colorScheme: ColorScheme(
          primary: _primary,
          primaryVariant: _primary,
          onPrimary: _secondary,
          secondary: _secondary,
          secondaryVariant: _secondary,
          onSecondary: Colors.white,
          surface: _primary,
          onSurface: _secondary,
          background: _primary,
          onBackground: _secondary,
          error: Colors.red,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
      );
    }

    return _lightThemeData;
  }

  ThemeData get darkThemeData {
    if (_darkThemeData == null) {
      final _primary = AppColors.darkGradientStart;
      final _secondary = Colors.white;
      final _disabled = Colors.grey;

      _darkThemeData = ThemeData(
        appBarTheme: AppBarTheme(
          color: AppColors.darkGradientEnd,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: Typography.whiteCupertino /*regular text*/,
        scaffoldBackgroundColor: _primary,
        accentColor: _secondary,
        disabledColor: _disabled,
        colorScheme: ColorScheme(
          primary: _primary,
          primaryVariant: _primary,
          onPrimary: _secondary,
          secondary: _secondary,
          secondaryVariant: _secondary,
          onSecondary: Colors.black,
          surface: _primary,
          onSurface: _secondary,
          background: _primary,
          onBackground: _secondary,
          error: Colors.red,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        dialogTheme: DialogTheme(backgroundColor: _primary),
      );
    }

    return _darkThemeData;
  }
}
