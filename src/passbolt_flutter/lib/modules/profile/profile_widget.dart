// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/analytics/AnalyticsEvents.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/router.dart';
import 'package:passbolt_flutter/common/state.dart';
import 'package:passbolt_flutter/common/ui/dialog.dart';
import 'package:passbolt_flutter/data/entities/user_profile.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/di/app_di_module_provider.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/di/auto_logout_injector.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/di/auto_logout_module.dart';
import 'package:passbolt_flutter/modules/profile/keys/key_widget.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/di/login_with_biometrics_injector.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/di/login_with_biometrics_module.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/login_with_biometrics_entities.dart';
import 'package:passbolt_flutter/modules/profile/profile_bloc.dart';
import 'package:passbolt_flutter/modules/profile/profile_entities.dart';
import 'package:pedantic/pedantic.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auto_logout/auto_logout_entities.dart';

class ProfileWidget extends StatefulWidget {
  final StateProfileWidget _stateImportKeyWidget;

  @provide
  const ProfileWidget(this._stateImportKeyWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateImportKeyWidget;
  }
}

class StateProfileWidget extends DefaultState<ProfileWidget> {
  final BaseProfileBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  StreamSubscription<BlocReaction> _reactionsSubscription;
  final _logger = Logger('StateProfileWidget');

  @provide
  StateProfileWidget(this._bloc, this._firebaseAnalytics) : super(_bloc);

  @override
  void initState() {
    super.initState();
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenProfile);
    _reactionsSubscription = _bloc.reactions.listen(
      (reaction) async {
        if (!mounted) return;
        switch (reaction.runtimeType) {
          case ErrorReaction:
            unawaited(
              showAlertDialog(
                context: context,
                message: (reaction as ErrorReaction).message,
              ),
            );
            break;
          default:
            return;
        }
      },
      cancelOnError: true,
    );
    _bloc.handle(FetchProfileIntent());
  }

  @override
  void dispose() {
    super.dispose();
    _reactionsSubscription.cancel();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: Theme.of(context).appBarTheme.textTheme.title),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder(
          stream: _bloc.states,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is ProfileState) {
                final profile = snapshot.data as ProfileState;

                final widgets = profile.items.map(
                  (element) {
                    return _buildProfileElementWidget(element, context);
                  },
                ).toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widgets,
                  ),
                );
              } else if (snapshot.data is ErrorState) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        (snapshot.data as ErrorState).message ?? 'Error',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      createButton(
                          label: 'Try again',
                          action: () {
                            setState(() {});
                          }),
                    ],
                  ),
                );
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileElementWidget(
    ProfileElement element,
    BuildContext context,
  ) {
    final oneRowItemSize = 42.0;
    final twoRowItemSize = 56.0;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.body2;
    final valueStyle = textTheme.body1;
    final valueSpace = 8.0;
    final sectionSpace = 24.0;
    final buttonSize = 16.0;
    final buttonColor = Colors.grey;

    switch (element.runtimeType) {
      case UserInfo:
        final imageSize = MediaQuery.of(context).size.width / 5;
        final userInfo = element as UserInfo;
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
          child: Row(
            children: <Widget>[
              if (!UserProfile.isDefaultAvatar(userInfo.userAvatarUrl))
                ClipRRect(
                  child: Image.network(
                    userInfo.userAvatarUrl,
                    width: imageSize,
                    height: imageSize,
                    loadingBuilder: (BuildContext context,
                        Widget currentRawImage, ImageChunkEvent event) {
                      if (event == null ||
                          event.cumulativeBytesLoaded == null ||
                          event.expectedTotalBytes == null ||
                          event.expectedTotalBytes == 0) {
                        return currentRawImage;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: event.cumulativeBytesLoaded /
                                event.expectedTotalBytes,
                          ),
                        );
                      }
                    },
                  ),
                  borderRadius: BorderRadius.circular(imageSize / 2),
                ),
              if (!UserProfile.isDefaultAvatar(userInfo.userAvatarUrl))
                SizedBox(
                  width: 16,
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    userInfo.userName,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: valueSpace,
                  ),
                  Text(
                    userInfo.userEmail,
                    style: valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: valueSpace,
                  ),
                  Text(
                    userInfo.userRole,
                    style: valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        );
        break;
      case Space:
        return SizedBox(
          height: sectionSpace,
          child: Center(
            child: Container(
              width: double.infinity,
              height: 1,
              color: Colors.black12,
            ),
          ),
        );
        break;
      case KeyInfo:
        final keyInfo = element as KeyInfo;
        return SizedBox(
          height: twoRowItemSize,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  keyInfo.title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: valueSpace,
                ),
                Text(
                  keyInfo.value,
                  style: valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
        break;
      case KeyInfoWithCopy:
        final keyInfoWithCopy = element as KeyInfoWithCopy;
        return SizedBox(
          height: twoRowItemSize,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        keyInfoWithCopy.title,
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: valueSpace,
                      ),
                      Text(
                        keyInfoWithCopy.value,
                        style: valueStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: RaisedButton(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      'copy',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: keyInfoWithCopy.value),
                      );
                      Scaffold.of(context).removeCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Copied to Clipboard',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                    color: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case KeyInfoWithRoute:
        final keyInfoWithRoute = element as KeyInfoWithRoute;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (buildContext) {
                  return KeyWidget(
                      keyInfoWithRoute.title, keyInfoWithRoute.keyData);
                },
              ),
            );
          },
          child: SizedBox(
            height: oneRowItemSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    keyInfoWithRoute.title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(CupertinoIcons.forward,
                      size: buttonSize, color: buttonColor),
                ],
              ),
            ),
          ),
        );
        break;
      case InfoWithUrl:
        final infoWithUrl = element as InfoWithUrl;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _launchUrl(infoWithUrl.url);
          },
          child: SizedBox(
            height: oneRowItemSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    infoWithUrl.title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(CupertinoIcons.forward,
                      size: buttonSize, color: buttonColor),
                ],
              ),
            ),
          ),
        );
        break;
      case Logout:
        final logout = element as Logout;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showAlertDialog(
                context: context,
                message: 'You are about logout. Are you sure?',
                action: () async {
                  await Navigator.of(context, rootNavigator: true).pop();
                  await Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteName.login.toString(),
                    (e) => false,
                  );
                },
                showCancelOption: true,
                positiveLabel: 'Yes',
                negativeLabel: 'No');
          },
          child: SizedBox(
            height: oneRowItemSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    logout.title,
                    style: titleStyle.copyWith(color: Colors.red),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
        );
        break;
      case AutoLogout:
        final autoLogout = element as AutoLogout;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            AppDiModule appDiModule =
                AppDiModuleProvider.of(context).appDiModule;

            final route = AutoLogoutInjector.createSync(
              AutoLogoutDiModule(
                AutoLogoutModuleIn("Auto logout settings", autoLogout.preset),
              ),
              appDiModule,
            ).widget();

            await Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (buildContext) {
                  return route;
                },
              ),
            );

            _bloc.handle(FetchProfileIntent());
          },
          child: SizedBox(
            height: oneRowItemSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    autoLogout.title,
                    style: titleStyle,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('${autoLogout.value}', style: valueStyle),
                      SizedBox(
                        width: valueSpace,
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        size: buttonSize,
                        color: buttonColor,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      case LoginWithBiometrics:
        final loginWithBiometrics = element as LoginWithBiometrics;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            AppDiModule appDiModule =
                AppDiModuleProvider.of(context).appDiModule;

            final route = LoginWithBiometricsInjector.createSync(
              LoginWithBiometricsDiModule(
                LoginWithBiometricsModuleIn(
                    loginWithBiometrics.title, loginWithBiometrics.value),
              ),
              appDiModule,
            ).widget();

            await Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (buildContext) {
                  return route;
                },
              ),
            );

            _bloc.handle(FetchProfileIntent());
          },
          child: SizedBox(
            height: oneRowItemSize,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    loginWithBiometrics.title,
                    style: titleStyle,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                          '${loginWithBiometrics.value ? 'Enabled' : 'Disabled'}',
                          style: valueStyle),
                      SizedBox(
                        width: valueSpace,
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        size: buttonSize,
                        color: buttonColor,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      default:
        return Spacer();
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _logger.warning('launch bad url $url');
    }
  }
}
