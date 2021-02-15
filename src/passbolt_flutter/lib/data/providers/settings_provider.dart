// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:logging/logging.dart';
import 'package:passbolt_flutter/common/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsKey { autoLogout, lastActivityTime, loginWithBiometrics }

extension SettingsKeyExtension on SettingsKey {
  Type get type {
    switch (this) {
      case SettingsKey.autoLogout:
        return int;
        break;
      case SettingsKey.lastActivityTime:
        return int;
        break;
      case SettingsKey.loginWithBiometrics:
        return bool;
        break;
      default:
        throw UnimplementedError();
        break;
    }
  }
}

enum AutoLogoutPreset { immediately, minutes1, minutes5, minutes10, minutes30 }

extension AutoLogoutPresetExtension on AutoLogoutPreset {
  int get milliseconds {
    return this.minutes * 60 * 1000;
  }

  int get minutes {
    switch (this) {
      case AutoLogoutPreset.immediately:
        return 0;
        break;
      case AutoLogoutPreset.minutes1:
        return 1;
        break;
      case AutoLogoutPreset.minutes5:
        return 5;
        break;
      case AutoLogoutPreset.minutes10:
        return 10;
        break;
      case AutoLogoutPreset.minutes30:
        return 30;
        break;
      default:
        throw UnimplementedError();
    }
  }
}

class Settings {
  final Map<SettingsKey, dynamic> _properties;

  AutoLogoutPreset get autoLogoutPreset {
    final int milliseconds = _properties[SettingsKey.autoLogout];
    return AutoLogoutPreset.values.firstWhere(
      (preset) {
        return preset.milliseconds == milliseconds;
      },
    );
  }

  int get lastActivityTime {
    return _properties[SettingsKey.lastActivityTime];
  }

  bool get loginWithBiometrics {
    return _properties[SettingsKey.loginWithBiometrics];
  }

  Settings(this._properties);

  T getProperty<T>(SettingsKey key) {
    return _properties[key] as T;
  }

  @override
  String toString() {
    return 'Settings ${_properties.entries.map(
      (entry) {
        return '\nkey: ${entry.key}, value: ${entry.value}';
      },
    ).join(' ')}';
  }
}

abstract class BaseSettingsProvider {
  Future<T> getProperty<T>(SettingsKey key);

  Future<void> setProperty<T>(SettingsKey key, T value);

  Future<Settings> getSettings();

  void init();
}

class SettingsProvider implements BaseSettingsProvider {
  final _logger = Logger('SettingsProvider');

  @override
  Future<T> getProperty<T>(SettingsKey key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _logger.finer('Get property T is $T key.type is ${key.type}');

    T property;

    final type = T != dynamic ? T : key.type;

    switch (type) {
      case int:
        property = await sharedPreferences.getInt(key.toString()) as T;
        break;
      case double:
        property = await sharedPreferences.getDouble(key.toString()) as T;
        break;
      case String:
        property = await sharedPreferences.getString(key.toString()) as T;
        break;
      case bool:
        property = await sharedPreferences.getBool(key.toString()) as T;
        break;
      default:
        throw UnimplementedError();
    }

    _logger.finer('Get property $key from sharedPreferences $property');
    return property;
  }

  @override
  Future<void> setProperty<T>(SettingsKey key, T value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _logger.finer('Set property T is $T key.type is ${key.type}');

    bool result;

    final type = T != dynamic ? T : key.type;

    switch (type) {
      case int:
        result = await sharedPreferences.setInt(key.toString(), value as int);
        break;
      case double:
        result =
            await sharedPreferences.setDouble(key.toString(), value as double);
        break;
      case String:
        result =
            await sharedPreferences.setString(key.toString(), value as String);
        break;
      case bool:
        result = await sharedPreferences.setBool(key.toString(), value as bool);
        break;
      default:
        throw UnimplementedError();
    }

    if (result == null || result == false) {
      throw SettingsProviderException(
        'SettingsProviderException. Unable to store value.',
      );
    }
  }

  @override
  Future<Settings> getSettings() async {
    final properties = Map<SettingsKey, dynamic>();

    await Future.forEach(
      SettingsKey.values,
      (SettingsKey key) async {
        dynamic property = await getProperty(key);
        properties[key] = property;
      },
    );

    final settings = Settings(properties);
    return settings;
  }

  @override
  void init() async {
    final settings = await getSettings();
    _logger.fine('Initial settings ${settings}');
    if (settings.getProperty(SettingsKey.autoLogout) == null) {
      await setProperty(
        SettingsKey.autoLogout,
        AutoLogoutPreset.minutes5.milliseconds,
      );
    }

    if (settings.getProperty(SettingsKey.loginWithBiometrics) == null) {
      await setProperty(SettingsKey.loginWithBiometrics, false);
    }
  }
}
