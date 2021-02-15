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
import 'package:passbolt_flutter/common/state.dart';
import 'package:passbolt_flutter/common/ui/dialog.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';
import 'package:passbolt_flutter/di/app_di_module.dart';
import 'package:passbolt_flutter/di/app_di_module_provider.dart';
import 'package:passbolt_flutter/modules/resource_crud/di/resource_crud_di_module.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_bloc.dart';
import 'package:passbolt_flutter/modules/resource_crud/resource_crud_entities.dart';
import 'package:passbolt_flutter/modules/secret/di/secret_injector.dart';
import 'package:passbolt_flutter/modules/secret/di/secret_module.dart';
import 'package:passbolt_flutter/modules/secret/secret_entities.dart';
import 'package:passbolt_flutter/tools/random_password.dart';
import 'package:password_strength/password_strength.dart';
import 'package:pedantic/pedantic.dart';

class ResourceCrudWidget extends StatefulWidget {
  final StateResourceCrudWidget _stateResourceCrudWidget;

  @provide
  const ResourceCrudWidget(this._stateResourceCrudWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateResourceCrudWidget;
  }
}

class StateResourceCrudWidget extends DefaultState<ResourceCrudWidget> {
  final _logger = Logger('StateResourceCrudWidget');
  final BaseResourceCrudBloc _bloc;
  final ResourceCrudModuleIn _moduleIn;
  final FirebaseAnalytics _firebaseAnalytics;
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _uriKey = GlobalKey<FormFieldState>();
  final _uriFocusNode = FocusNode();
  final _userNameKey = GlobalKey<FormFieldState>();
  final _userNameFocusNode = FocusNode();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _passwordFocusNode = FocusNode();
  final _descriptionKey = GlobalKey<FormFieldState>();
  final _descriptionFocusNode = FocusNode();
  final _buttonFocusNode = FocusNode();
  final double _horizontalPadding = 24.0;
  final double _strengthLabelWidth = 100.0;
  bool _isPasswordRevealed = false;
  bool _isEmptyPasswordInEditMode = true;
  TextEditingController _passwordController = TextEditingController();
  StreamSubscription _reactionsSubscription;

  @provide
  StateResourceCrudWidget(this._bloc, this._moduleIn, this._firebaseAnalytics)
      : super(_bloc);

  @override
  void initState() {
    super.initState();
    switch (_moduleIn.mode) {
      case ResourceCrudMode.edit:
        _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenResourceEdit);
        break;
      case ResourceCrudMode.create:
        _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenResourceCreate);
        break;
    }

    _reactionsSubscription = _bloc.reactions.listen(
      (reaction) async {
        if (!mounted) return;
        switch (reaction.runtimeType) {
          case ResourceCreatedReaction:
            AppDiModule appDiModule =
                AppDiModuleProvider.of(context).appDiModule;

            final route = SecretInjector.createSync(
              SecretDiModule(
                SecretModuleIn((reaction as ResourceCreatedReaction).resource),
              ),
              ResourceCrudDiModule(null),
              appDiModule,
            ).widget();

            unawaited(
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (buildContext) {
                    return route;
                  },
                ),
              ),
            );
            break;
          case ResourceUpdatedReaction:
            Navigator.of(context).pop(
              (reaction as ResourceUpdatedReaction).resource,
            );
            break;
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
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _reactionsSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fieldSpace = 24.0;
    final buttonCreateHeight = 48.0;
    final buttonHeight = 34.0;
    final buttonWidth = 48.0;
    final buttonImageSize = 24.0;

    Widget buttonVisibility = GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).unfocus();
          _isPasswordRevealed = !_isPasswordRevealed;
        });
      },
      child: Container(
        child: Icon(
            _isPasswordRevealed ? Icons.visibility_off : Icons.visibility,
            size: buttonImageSize,
            color: Colors.grey),
        width: buttonWidth,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
      ),
    );

    Widget buttonCreatePassword = GestureDetector(
      onTap: () {
        setState(() {
          FocusScope.of(context).unfocus();
          _passwordController.text = RandomPassword.create();
        });
      },
      child: Container(
        width: buttonWidth,
        child: Center(
          child: SizedBox(
            width: buttonImageSize,
            height: buttonImageSize,
            child: Image.asset(
              'assets/images/ic_create_password.png',
              color: Colors.grey,
            ),
          ),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _moduleIn.mode == ResourceCrudMode.create
              ? 'Create password'
              : 'Edit password',
          style: Theme.of(context).appBarTheme.textTheme.title,
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        initialData: ResourceCrudState(),
        stream: _bloc.states,
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data as BlocState;

            if (_moduleIn.mode == ResourceCrudMode.edit &&
                _isEmptyPasswordInEditMode &&
                (_passwordController.text == null ||
                    _passwordController.text.isEmpty)) {
              _isEmptyPasswordInEditMode = false;
              _passwordController.text = _moduleIn.decryptedPassword;
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: fieldSpace,
                      ),
                      TextFormField(
                        key: _nameKey,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(_uriFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _moduleIn.mode == ResourceCrudMode.edit
                            ? _moduleIn.resource.name
                            : null,
                      ),
                      SizedBox(
                        height: fieldSpace,
                      ),
                      TextFormField(
                        key: _uriKey,
                        keyboardType: TextInputType.url,
                        focusNode: _uriFocusNode,
                        autocorrect: false,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (v) {
                          FocusScope.of(context)
                              .requestFocus(_userNameFocusNode);
                        },
                        decoration: InputDecoration(
                          labelText: 'URI',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _moduleIn.mode == ResourceCrudMode.edit
                            ? _moduleIn.resource.uri
                            : null,
                      ),
                      SizedBox(
                        height: fieldSpace,
                      ),
                      TextFormField(
                        key: _userNameKey,
                        keyboardType: TextInputType.text,
                        focusNode: _userNameFocusNode,
                        autocorrect: false,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (v) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        decoration: InputDecoration(
                          labelText: 'User name',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _moduleIn.mode == ResourceCrudMode.edit
                            ? _moduleIn.resource.username
                            : null,
                      ),
                      SizedBox(
                        height: fieldSpace,
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 58,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    key: _passwordKey,
                                    keyboardType: TextInputType.visiblePassword,
                                    focusNode: _passwordFocusNode,
                                    textInputAction: TextInputAction.go,
                                    controller: _passwordController,
                                    autocorrect: false,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context)
                                          .requestFocus(_descriptionFocusNode);
                                    },
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    obscureText:
                                        _isPasswordRevealed ? false : true,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter password';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                buttonVisibility,
                                SizedBox(width: 4),
                                buttonCreatePassword,
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: <Widget>[
                              _buildPasswordStrengthWidget(
                                  _passwordController.text),
                              SizedBox(
                                height: 4,
                              ),
                              SizedBox(
                                width: _strengthLabelWidth,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'complexity: ${_estimatePasswordStrength(_passwordController.text)}',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: fieldSpace,
                      ),
                      TextFormField(
                        key: _descriptionKey,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        focusNode: _descriptionFocusNode,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(_buttonFocusNode);
                        },
                        decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            fillColor: Colors.black12),
                        initialValue: _moduleIn.mode == ResourceCrudMode.edit
                            ? _moduleIn.resource.description
                            : null,
                      ),
                      SizedBox(
                        height: fieldSpace * 2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: double.infinity,
                            height: buttonCreateHeight,
                            child: _buildButton(state),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildButton(BlocState state) {
    if (state is PendingState) {
      return createButton(
        label: 'Pending',
        color: Colors.grey,
        focusNode: _buttonFocusNode,
      );
    } else {
      return createButton(
        label: _moduleIn.mode == ResourceCrudMode.edit ? 'Edit' : 'Create',
        action: () {
          if (_moduleIn.mode == ResourceCrudMode.edit) {
            _onEditPressed();
          } else {
            _onCreatePressed();
          }
        },
        focusNode: _buttonFocusNode,
      );
    }
  }

  Widget _buildPasswordStrengthWidget(String password) {
    final double passwordStrength = estimatePasswordStrength(password);
    final widgetWidth = MediaQuery.of(this.context).size.width -
        2 * _horizontalPadding -
        _strengthLabelWidth -
        4;
    double width = widgetWidth * passwordStrength;
    Widget widget;

    if (password == null || password.isEmpty) {
      width = widgetWidth;
      widget = Container();
    } else if (passwordStrength < 0.3) {
      widget = Container(color: Colors.red);
    } else if (passwordStrength < 0.6) {
      widget = Container(color: Colors.yellow);
    } else {
      widget = Container(color: Colors.green);
    }

    return SizedBox(
      width: widgetWidth,
      height: 8,
      child: Container(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: width,
            child: widget,
          ),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  String _estimatePasswordStrength(String password) {
    if (password == null || password.isEmpty) {
      return 'n/a';
    }

    double passwordStrength = estimatePasswordStrength(password);

    if (passwordStrength < 0.3) {
      return 'weak';
    } else if (passwordStrength < 0.6) {
      return 'good';
    } else {
      return 'strong';
    }
  }

  void _onCreatePressed() async {
    if (mounted) {
      if (_formKey.currentState.validate()) {
        final String name = _nameKey.currentState.value;
        final String uri = _uriKey.currentState.value;
        final String userName = _userNameKey.currentState.value;
        final String password = _passwordKey.currentState.value;
        final String description = _descriptionKey.currentState.value;
        _bloc.handle(
          CreateResourceIntent(
            name: name,
            uri: uri,
            userName: userName,
            password: password,
            description: description,
          ),
        );
      }
    }
  }

  void _onEditPressed() async {
    if (mounted) {
      if (_formKey.currentState.validate()) {
        final String name = _nameKey.currentState.value;
        final String uri = _uriKey.currentState.value;
        final String userName = _userNameKey.currentState.value;
        final String password = _passwordKey.currentState.value;
        final String description = _descriptionKey.currentState.value;
        _bloc.handle(
          UpdateResourceIntent(
            resourceId: _moduleIn.resource.id,
            name: name,
            uri: uri,
            userName: userName,
            password: password,
            description: description,
          ),
        );
      }
    }
  }
}
