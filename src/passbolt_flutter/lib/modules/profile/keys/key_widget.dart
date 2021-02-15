// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passbolt_flutter/data/providers/theme_data_provider.dart';

class KeyWidget extends StatefulWidget {
  final String title;
  final String keyData;

  const KeyWidget(this.title, this.keyData);

  @override
  State<StatefulWidget> createState() {
    return _StateKeyWidget(title, keyData);
  }
}

class _StateKeyWidget extends State<KeyWidget> {
  final String title;
  final String keyData;

  _StateKeyWidget(this.title, this.keyData);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).appBarTheme.textTheme.title),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Text(keyData, style: textTheme.caption),
              ),
            ),
            SizedBox(
              height: 32,
            ),
            SizedBox(
              width: double.infinity,
              child: createButton(
                label: 'Copy to clipboard',
                action: () {
                  Clipboard.setData(ClipboardData(text: keyData));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
