import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, Widget content,
    {String continueText = 'Confirm', GestureTapCallback onConfirm}) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = FlatButton(
    child: Text(continueText),
    onPressed: () {
      Navigator.of(context).pop();
      onConfirm();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Confirm action"),
    content: content,
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
