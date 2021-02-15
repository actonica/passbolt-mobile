// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:passbolt_flutter/common/ui/dialog.dart';
import 'package:passbolt_flutter/data/providers/settings_provider.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/auto_logout_bloc.dart';
import 'package:passbolt_flutter/modules/profile/auto_logout/auto_logout_entities.dart';

class AutoLogoutWidget extends StatefulWidget {
  final StateAutoLogoutWidget _stateAutoLogoutWidget;

  @provide
  const AutoLogoutWidget(this._stateAutoLogoutWidget);

  @override
  State<StatefulWidget> createState() {
    return _stateAutoLogoutWidget;
  }
}

class StateAutoLogoutWidget extends State<AutoLogoutWidget> {
  final BaseAutoLogoutBloc _bloc;
  final AutoLogoutModuleIn _moduleIn;
  AutoLogoutPreset _currentValue;

  @provide
  StateAutoLogoutWidget(this._bloc, this._moduleIn)
      : _currentValue = _moduleIn.currentValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final widgets = AutoLogoutPreset.values.map(
      (value) {
        return _buildItemWidget(value);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_moduleIn.title, style: Theme.of(context).appBarTheme.textTheme.title),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
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
      ),
    );
  }

  Widget _buildItemWidget(AutoLogoutPreset preset) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final result = await _bloc.updateAutoLogout(preset);

        if (mounted) {
          if (result) {
            setState(() {
              _currentValue = preset;
            });
          } else {
            await showAlertDialog(context: context, message: 'Error. Try again, please.');
          }
        }
      },
      child: SizedBox(
        height: 56,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              if (preset == _currentValue)
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
                preset.minutes > 0 ? '${preset.minutes} min' : 'immediately',
                style: textTheme.body1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
