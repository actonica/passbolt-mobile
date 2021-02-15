// ©2019-2020 Actonica LLC - All Rights Reserved

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:passbolt_flutter/common/bloc.dart';
import 'package:passbolt_flutter/common/router.dart';

abstract class DefaultState<T extends StatefulWidget> extends State<T> {
  final Bloc _bloc;

  StreamSubscription _unauthorizedSubscription;

  DefaultState(this._bloc);

  @override
  void initState() {
    super.initState();
    _unauthorizedSubscription = _bloc.unauthorized.listen(
      (reaction) async {
        if (!mounted) return;
        if (reaction is UnauthorizedReaction) {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            RouteName.login.toString(),
            (e) => false,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _unauthorizedSubscription.cancel();
    super.dispose();
  }
}
