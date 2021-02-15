// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';
import 'package:logging/logging.dart';
import 'package:passbolt_flutter/analytics/AnalyticsEvents.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/router.dart';
import 'package:passbolt_flutter/common/ui/dialog.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_bloc.dart';
import 'package:passbolt_flutter/modules/verify_server/verify_server_entities.dart';

class VerifyServerWidget extends StatefulWidget {
  final StateVerifyServerWidget _stateVerifyServerWidget;

  @provide
  const VerifyServerWidget(this._stateVerifyServerWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateVerifyServerWidget;
  }
}

class StateVerifyServerWidget extends State<VerifyServerWidget> {
  final BaseVerifyServerBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  final _formKey = GlobalKey<FormState>();
  final _urlKey = GlobalKey<FormFieldState>();
  final _fingerprintKey = GlobalKey<FormFieldState>();
  final _logger = Logger('_StateVerifyServerWidget');
  StreamSubscription<BlocReaction> _reactionsSubscription;

  @provide
  StateVerifyServerWidget(this._bloc, this._firebaseAnalytics);

  @override
  void initState() {
    super.initState();
    _reactionsSubscription = _bloc.reactions.listen((reaction) async {
      if (!mounted) return;

      switch (reaction.runtimeType) {
        case NavigateToImportKeyReaction:
          FocusScope.of(context).unfocus();
          await Navigator.of(context)
              .pushNamed(RouteName.importPrivateKey.toString());
          break;
        case ErrorReaction:
          await showAlertDialog(
            context: context,
            message: (reaction as ErrorReaction).message,
          );
          break;
        default:
          throw UnimplementedError();
      }
    }, cancelOnError: true);
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenVerifyServer);
  }

  @override
  void dispose() {
    super.dispose();
    _reactionsSubscription.cancel();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textThemes = Theme.of(context).textTheme;
    final fingerprintFocus = FocusNode();

    return Scaffold(
      body: StreamBuilder(
        initialData: VerifyServerState(),
        stream: _bloc.states,
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            _logger.fine(snapshot.data);

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
                padding: EdgeInsets.all(32),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Server check',
                          style: textThemes.title,
                        ),
                      ),
                    ),
                    Text(
                      'You are about to register the app to work with the following domain. Please confirm that this is a domain managed by an organisation you trust: ',
                      textAlign: TextAlign.justify,
                      style: textThemes.body1,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Passbolt server url'),
                          TextFormField(
                            key: _urlKey,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.go,
                            autocorrect: false,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context)
                                  .requestFocus(fingerprintFocus);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter passbolt server url';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text('Your public key fingerprint'),
                          TextFormField(
                            key: _fingerprintKey,
                            focusNode: fingerprintFocus,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            onEditingComplete: () {
                              _onNextPressed();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your public key fingerpring';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: _buildButton(
                        snapshot.data,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (snapshot.data is ErrorState)
                      Text(
                        (snapshot.data as ErrorState).message,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.error),
                      ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              ),
            );

            return widget;
          }

          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(BlocState state) {
    if (state is PendingState) {
      return createButton(label: 'Pending...', color: Colors.grey);
    } else {
      return createButton(label: 'Verify', action: _onNextPressed);
    }
  }

  void _onNextPressed() async {
    if (mounted) {
      if (_formKey.currentState.validate()) {
        String passboltServerUrl = _urlKey.currentState.value;
        String fingerprint = _fingerprintKey.currentState.value;
        _logger.fine(
            'form is not empty - url $passboltServerUrl fingerprint $fingerprint');
        _bloc.handle(CheckIntent(passboltServerUrl, fingerprint));
      }
    }
  }
}
