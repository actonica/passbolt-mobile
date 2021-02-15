// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inject/inject.dart';
import 'package:pedantic/pedantic.dart';

import '../../analytics/AnalyticsEvents.dart';
import '../../common/router.dart';
import '../../common/ui/dialog.dart';
import '../../data/providers/theme_data_provider.dart';
import 'login_bloc.dart';
import 'login_entities.dart';

class LoginWidget extends StatefulWidget {
  final LoginBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;

  @provide
  const LoginWidget(this._bloc, this._firebaseAnalytics);

  @override
  State<StatefulWidget> createState() {
    return StateLoginWidget(_bloc, _firebaseAnalytics);
  }
}

class StateLoginWidget extends State<LoginWidget> {
  final LoginBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  final _formKey = GlobalKey<FormState>();
  final _passphraseKey = GlobalKey<FormFieldState>();

  StateLoginWidget(this._bloc, this._firebaseAnalytics);

  @override
  void initState() {
    super.initState();
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenLogin);
  }

  @override
  Widget build(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildContentView(context, 16),
      );
    } else {
      return Scaffold(
        body: _buildContentView(context, 32),
      );
    }
  }

  Widget _buildContentView(BuildContext context, double topPadding) {
    final passphraseFocus = FocusNode();

    return BlocConsumer(
      cubit: _bloc,
      buildWhen: (previous, current) {
        return current is InitialLoginState ||
            current is PendingInitialLoginState;
      },
      builder: (context, state) {
        if (state is InitialLoginState) {
          final widget = Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkGradientStart,
                  AppColors.darkGradientEnd,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 32,
                right: 32,
                top: topPadding,
                bottom: 32,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 256,
                        height: 256,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (state.userName != null)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Username'),
                              SizedBox(
                                height: 16,
                              ),
                              Text(state.userName),
                              SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                        Text('Passphrase'),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: _passphraseKey,
                                keyboardType: TextInputType.visiblePassword,
                                autocorrect: false,
                                focusNode: passphraseFocus,
                                initialValue: '',
                                textInputAction: TextInputAction.done,
                                onEditingComplete: () {
                                  _onNextPressed();
                                },
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter passphrase for your private key';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (state.isLoginWithBiometricsEnabled)
                              IconButton(
                                icon: Icon(Icons.fingerprint),
                                onPressed: () {
                                  _bloc.add(LoginWithBiometryEvent());
                                },
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: _buildButton(),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Login to another server',
                      style: TextStyle(color: Colors.white54),
                    ),
                    onTap: _onLoginToAnotherServer,
                  ),
                ],
              ),
            ),
          );

          return widget;
        } else if (state is PendingInitialLoginState) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          throw UnimplementedError();
        }
      },
      listenWhen: (previous, current) {
        return current is! InitialLoginState &&
            current is! PendingInitialLoginState;
      },
      listener: (context, state) async {
        if (state is! PendingLoginState) {
          await Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is PendingLoginState) {
          unawaited(
            showCircularPendingDialog(context: context),
          );
        } else if (state is SuccessfulLoginState) {
          unawaited(
            Navigator.of(context).pushNamedAndRemoveUntil(
                RouteName.resources.toString(), (e) => false),
          );
        } else if (state is DeleteCurrentServerDataState) {
          unawaited(
            Navigator.of(context).pushNamedAndRemoveUntil(
                RouteName.verifyServer.toString(), (e) => false),
          );
        } else if (state is NeedAutofillValuesState) {
          unawaited(
            Navigator.of(context).pushNamedAndRemoveUntil(
                RouteName.autofillValues.toString(), (e) => false),
          );
        } else if (state is ErrorLoginState) {
          if (state.message != 'Canceled') {
            unawaited(
              showAlertDialog(
                context: context,
                message: state.message,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildButton() {
    return createButton(label: 'Login', action: _onNextPressed);
  }

  void _onLoginToAnotherServer() async {
    if (mounted) {
      unawaited(
        showAlertDialog(
            context: context,
            message:
                'You are about to delete current server settings. Are you sure?',
            action: () async {
              if (mounted) {
                _bloc.add(DeleteCurrentServerDataEvent());
              }
            },
            showCancelOption: true,
            titleLabel: 'Delete server settings',
            positiveLabel: 'Yes',
            negativeLabel: 'No'),
      );
    }
  }

  void _onNextPressed() async {
    if (mounted) {
      if (_formKey.currentState.validate()) {
        String passphrase = _passphraseKey.currentState.value;
        _bloc.add(LoginWithPassphraseEvent(passphrase));
      }
    }
  }
}
