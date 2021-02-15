// ©2019-2020 Actonica LLC - All Rights Reserved

import 'package:flutter/material.dart';

Future<void> showAlertDialog(
    {@required BuildContext context,
    @required String message,
    Function action,
    bool showCancelOption,
    String titleLabel,
    String positiveLabel,
    String negativeLabel}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;

      final okOption = SimpleDialogOption(
        child: Text(
          positiveLabel ?? "OK",
          style: textTheme.button,
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          if (action != null) {
            action();
          } else {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      );

      Widget optionsWidget;

      if (showCancelOption ?? false) {
        final cancelOption = SimpleDialogOption(
          child: Text(
            negativeLabel ?? "Cancel",
            style: textTheme.button,
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        );

        optionsWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[okOption, cancelOption],
        );
      } else {
        optionsWidget = okOption;
      }

      return WillPopScope(
        child: SimpleDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          children: <Widget>[
            if (titleLabel != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  titleLabel,
                  style: textTheme.headline,
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                message,
                style: textTheme.body1,
                textAlign: TextAlign.center,
              ),
            ),
            optionsWidget,
          ],
        ),
        onWillPop: () async {
          return false;
        },
      );
    },
  );
}

Future<void> showPendingDialog({
  @required BuildContext context,
  @required String message,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return WillPopScope(
        child: SimpleDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Processing',
                style: textTheme.headline,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                style: textTheme.body1,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
        onWillPop: () async {
          return false;
        },
      );
    },
  );
}

Future<void> showCircularPendingDialog({
  @required BuildContext context,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        child: Center(child: CircularProgressIndicator(),),
        onWillPop: () async {
          return false;
        },
      );
    },
  );
}
