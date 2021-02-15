// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';

enum KeyInfoRoute { public, private }

class FetchProfileIntent extends UserIntent {}

abstract class BaseProfileState implements BlocState {}

class ProfileState implements BaseProfileState {
  final List<ProfileElement> items;

  ProfileState({@required this.items});
}

abstract class ProfileElement {}

class UserInfo implements ProfileElement {
  final String userName;
  final String userEmail;
  final String userRole;
  final String userAvatarUrl;

  UserInfo({
    @required this.userName,
    @required this.userEmail,
    @required this.userRole,
    @required this.userAvatarUrl,
  });
}

class AutoLogout implements ProfileElement {
  final String title;
  final String value;
  final AutoLogoutPreset preset;

  AutoLogout({
    @required this.title,
    @required this.value,
    @required this.preset,
  });
}

class LoginWithBiometrics implements ProfileElement {
  final String title;
  final bool value;

  LoginWithBiometrics({@required this.title, @required this.value});
}

class Space implements ProfileElement {}

class KeyInfo implements ProfileElement {
  final String title;
  final String value;

  KeyInfo({@required this.title, @required this.value});
}

class KeyInfoWithCopy implements ProfileElement {
  final String title;
  final String value;

  KeyInfoWithCopy({@required this.title, @required this.value});
}

class KeyInfoWithRoute implements ProfileElement {
  final String title;
  final String keyData;
  final KeyInfoRoute route;

  KeyInfoWithRoute({
    @required this.title,
    @required this.keyData,
    @required this.route,
  });
}

class InfoWithUrl implements ProfileElement {
  final String title;
  final String url;

  InfoWithUrl({@required this.title, @required this.url});
}

class Logout implements ProfileElement {
  final String title;

  Logout({@required this.title});
}
