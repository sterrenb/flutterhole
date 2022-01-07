import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/widgets/layout/code_card.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  String? title,
  Widget? body,
  bool canCancel = true,
  String? cancelLabel,
  String? okLabel,
  Color? okColor,
  Color? backgroundColor,
}) =>
    showDialog(
        context: context,
        builder: (context) => ModalAlertDialog<bool>(
              title: title,
              body: body,
              popValue: true,
              cancelValue: false,
              canCancel: canCancel,
              cancelLabel: cancelLabel,
              okLabel: okLabel,
              okColor: okColor,
              backgroundColor: backgroundColor,
            ));

Future<bool?> showScrollableConfirmationDialog(
  BuildContext context, {
  String? title,
  Widget? body,
  bool canCancel = true,
  String? cancelLabel,
  String? okLabel,
  Color? okColor,
  EdgeInsetsGeometry? contentPadding,
}) =>
    showDialog(
        context: context,
        builder: (context) => ModalAlertDialog<bool>(
              title: title,
              body: SingleChildScrollView(child: body),
              popValue: true,
              cancelValue: false,
              canCancel: canCancel,
              cancelLabel: cancelLabel,
              okLabel: okLabel,
              okColor: okColor,
              contentPadding: contentPadding,
            ));

Future<bool?> showDeleteConfirmationDialog(
        BuildContext context, String message) =>
    showConfirmationDialog(
      context,
      title: message,
      okLabel: 'Delete',
      okColor: Theme.of(context).colorScheme.error,
    );

Future<bool?> showSaveChangesDialog(context) => showConfirmationDialog(
      context,
      title: 'Save changes?',
      okLabel: 'Save',
      cancelLabel: 'Discard',
    );

class ModalAlertDialog<T> extends StatelessWidget {
  const ModalAlertDialog({
    Key? key,
    required this.title,
    this.body,
    this.popValue,
    this.cancelValue,
    this.canCancel = true,
    this.cancelLabel,
    this.okLabel,
    this.okColor,
    this.backgroundColor,
    this.contentPadding,
  }) : super(key: key);

  final String? title;
  final Widget? body;
  final T? popValue;
  final T? cancelValue;
  final bool canCancel;
  final String? cancelLabel;
  final String? okLabel;
  final Color? okColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      title: title != null ? Text(title!) : null,
      content: body,
      contentPadding:
          contentPadding ?? const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      actions: <Widget>[
        canCancel
            ? TextButton(
                onPressed: () => Navigator.of(context).pop(cancelValue),
                child: Text(cancelLabel?.toUpperCase() ??
                    MaterialLocalizations.of(context).cancelButtonLabel))
            : Container(),
        TextButton(
            onPressed: () => Navigator.of(context).pop(popValue),
            child: Text(
              okLabel?.toUpperCase() ??
                  MaterialLocalizations.of(context).okButtonLabel,
              style: TextStyle(color: okColor),
            )),
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
      // backgroundColor: Theme.of(context).dialogBackgroundColor,
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // backgroundColor: Colors.transparent,
      title: Text(title),
      content: SingleChildScrollView(
        child: MobileMaxWidth(
          center: false,
          // backgroundColor: Theme.of(context).dialogBackgroundColor,
          // foregroundColor: Theme.of(context).dialogBackgroundColor,
          foregroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(Formatting.errorToDescription(error)),
              // SingleChildScrollView(
              //   child: Column(
              //     children: [
              //       // SizedBox(height: 20.0),
              stackTrace != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child:
                          CodeCard(stackTrace.toString(), maxLines: maxLines),
                    )
                  : Container(),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class CenteredErrorMessage extends StatelessWidget {
  const CenteredErrorMessage(
    this.error, {
    this.stackTrace,
    this.message,
    this.showIcon = false,
    Key? key,
  }) : super(key: key);

  final Object error;
  final StackTrace? stackTrace;
  final String? message;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        minimum: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                KIcons.error,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24.0),
            ],
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