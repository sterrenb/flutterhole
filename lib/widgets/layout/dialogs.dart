import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  Widget title,
}) async {
  final result = await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: title ?? Text('Confirm'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            OutlineButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      });

  return result ?? false;
}
