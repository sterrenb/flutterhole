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
    return Center(
      child: ListTile(
        title: Text('${failure.message ?? 'Unknown failure'}'),
        subtitle: Text('${failure.error?.runtimeType ?? 'Unknown error'}'),
        trailing: Icon(
          KIcons.warning,
          color: KColors.warning,
        ),
        onTap: () {
          showFailureDialog(context, failure);
        },
      ),
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
