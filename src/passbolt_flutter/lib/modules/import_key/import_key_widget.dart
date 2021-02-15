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
import 'package:passbolt_flutter/modules/import_key/import_key_bloc.dart';
import 'package:passbolt_flutter/modules/import_key/import_key_entities.dart';
import 'package:pedantic/pedantic.dart';

class ImportKeyWidget extends StatefulWidget {
  final StateImportKeyWidget _stateImportKeyWidget;

  @provide
  const ImportKeyWidget(this._stateImportKeyWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateImportKeyWidget;
  }
}

class StateImportKeyWidget extends State<ImportKeyWidget> {
  final BaseImportKeyBloc _bloc;
  final FirebaseAnalytics _firebaseAnalytics;
  final _textEditingController = TextEditingController();
  final _logger = Logger('_StateImportKeyWidget');
  StreamSubscription<BlocReaction> _reactionsSubscription;

  @provide
  StateImportKeyWidget(this._bloc, this._firebaseAnalytics);

  @override
  void initState() {
    super.initState();
    _reactionsSubscription = _bloc.reactions.listen(
      (reaction) async {
        if (!mounted) return;
        switch (reaction.runtimeType) {
          case NavigateToLoginReaction:
            unawaited(
              Navigator.of(context).pushNamed(RouteName.login.toString()),
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
            throw UnimplementedError();
        }
      },
      cancelOnError: true,
    );
    _firebaseAnalytics.logEvent(name: AnalyticsEvents.screenImportPrivateKey);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
    _reactionsSubscription.cancel();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textThemes = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 32,
          right: 32,
          top: 16,
          bottom: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              'Import your key',
              style: textThemes.title,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'To recover an account, enter private key',
              style: textThemes.body1,
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
              flex: 10,
              child: Container(
                color: AppColors.darkGradientEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _textEditingController,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {
                      _onNextPressed();
                    },
                    style: TextStyle(fontSize: 8),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                    ),
                    maxLines: 200,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 32,
            ),
            SizedBox(
              width: double.infinity,
              child: createButton(
                label: 'Test and continue',
                action: _onNextPressed,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            )
          ],
        ),
      ),
    );
  }

  void _onNextPressed() async {
    if (mounted) {
      FocusScope.of(context).unfocus();
      _bloc.handle(ImportKeyIntent(_textEditingController.text));
    }
  }
}
