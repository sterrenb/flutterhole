import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';

class CenteredFailureIndicator extends StatelessWidget {
  const CenteredFailureIndicator(
    this.failure, {
    Key key,
  }) : super(key: key);

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('${failure.message ?? 'unknown failure'}'),
        Text('${failure.error?.toString()}'),
      ],
    );
  }
}

class FailureIconButton extends StatelessWidget {
  const FailureIconButton({
    Key key,
    @required this.failure,
    this.title,
  }) : super(key: key);

  final Failure failure;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Show failure',
      icon: Icon(
        KIcons.error,
        color: KColors.error,
      ),
      onPressed: () {
        showFailureDialog(
          context,
          failure,
          title: title,
        );
      },
    );
  }
}
