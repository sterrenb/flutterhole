import 'package:flutter/material.dart';
import 'package:flutterhole_web/dialogs.dart';

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
        minimum: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message ?? error.toString()),
            const SizedBox(height: 8.0),
            TextButton(
                child: Text('View details'),
                onPressed: () {
                  showErrorDialog(context, error, stackTrace);
                  // context.refresh(_markdownProvider);
                }),
          ],
        ),
      ),
    );
  }
}
