import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/widgets/layout/code_card.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
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
    this.maxLines = 5,
  }) : super(key: key);

  final String title;
  final Object error;
  final StackTrace? stackTrace;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: MobileMaxWidth(
        center: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Formatting.errorToDescription(error)),
              // SizedBox(height: 20.0),
              stackTrace != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child:
                          CodeCard(stackTrace.toString(), maxLines: maxLines),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class CenteredErrorMessage extends StatelessWidget {
  const CenteredErrorMessage(
    this.error,
    this.stackTrace, {
    this.message,
    Key? key,
  }) : super(key: key);

  final Object error;
  final StackTrace? stackTrace;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        minimum: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message ?? error.toString()),
            const SizedBox(height: 8.0),
            TextButton(
                child: const Text('View details'),
                onPressed: () {
                  showModal(
                      context: context,
                      builder: (context) => ErrorDialog(
                          title: 'Error',
                          error: error,
                          stackTrace: stackTrace));
                  // context.refresh(_markdownProvider);
                }),
          ],
        ),
      ),
    );
  }
}
