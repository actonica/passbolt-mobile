// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/ui/dialog.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/login_with_biometrics_bloc.dart';
import 'package:passbolt_flutter/modules/profile/login_with_biometrics/login_with_biometrics_entities.dart';
import 'package:pedantic/pedantic.dart';

class LoginWithBiometricsWidget extends StatefulWidget {
  final StateLoginWithBiometricsWidget _state;

  @provide
  const LoginWithBiometricsWidget(this._state);

  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class StateLoginWithBiometricsWidget extends State<LoginWithBiometricsWidget> {
  final BaseLoginWithBiometricsBloc _bloc;
  final LoginWithBiometricsModuleIn _moduleIn;
  StreamSubscription _reactionsSubscription;

  @provide
  StateLoginWithBiometricsWidget(this._bloc, this._moduleIn);

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _reactionsSubscription.cancel();
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_moduleIn.title,
            style: Theme.of(context).appBarTheme.textTheme.title),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        initialData: LoginWithBiometricsState(_moduleIn.currentValue),
        stream: _bloc.states,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data is LoginWithBiometricsState) {
            final currentValue =
                (snapshot.data as LoginWithBiometricsState).currentValue;

            final widgets = [
              _buildItemWidget(true, currentValue),
              _buildItemWidget(false, currentValue),
            ];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                itemBuilder: (buildContext, index) {
                  return widgets[index];
                },
                separatorBuilder: (buildContext, index) {
                  return Container(
                    color: Colors.black12,
                    height: 1,
                  );
                },
                itemCount: widgets.length,
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildItemWidget(bool value, bool currentValue) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _bloc.handle(ChangeLoginWithBiometricsIntent(value));
      },
      child: SizedBox(
        height: 56,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              if (value == currentValue)
                Icon(
                  Icons.radio_button_checked,
                  size: 16,
                  color: Colors.grey,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  size: 16,
                  color: Colors.grey,
                ),
              SizedBox(width: 16),
              Text(
                value ? 'Enabled' : 'Disabled',
                style: textTheme.body1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
