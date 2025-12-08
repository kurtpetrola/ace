// lib/common/widgets/dialogs/alertdialog.dart

import 'package:flutter/material.dart';

enum DialogsAction { yes, cancel }

class AlertDialogs {
  static Future<DialogsAction> yesCancelDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.only(top: 200, bottom: 200),
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: Theme.of(context).textTheme.titleLarge?.color),
          contentTextStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color),
          buttonPadding: const EdgeInsets.all(10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(130.0, 45.0),
                backgroundColor: Theme.of(context).cardTheme.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(DialogsAction.cancel),
              child: Text(
                'CANCEL',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(130.0, 45.0),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(DialogsAction.yes),
              child: Text(
                'CONFIRM',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            )
          ],
        );
      },
    );
    return (action != null) ? action : DialogsAction.cancel;
  }
}
