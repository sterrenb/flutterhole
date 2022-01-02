import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/widgets/layout/code_card.dart';
import 'package:pihole_api/pihole_api.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required Widget body,
}) {
  return showDialog(
      context: context,
      builder: (context) => ModalAlertDialog<bool>(
            title: title,
            body: body,
            popValue: true,
          ));
}

class ModalAlertDialog<T> extends StatelessWidget {
  const ModalAlertDialog({
    Key? key,
    required this.title,
    required this.body,
    this.popValue,
  }) : super(key: key);

  final String title;
  final Widget body;
  final T? popValue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: body,
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        TextButton(
            onPressed: () => Navigator.of(context).pop(popValue),
            child: Text(MaterialLocalizations.of(context).okButtonLabel)),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    Key? key,
    required this.title,
    required this.error,
    this.stackTrace,
  }) : super(key: key);

  final String title;
  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Formatting.errorToDescription(error)),
            // SizedBox(height: 20.0),
            stackTrace != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: CodeCard(stackTrace.toString()),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
