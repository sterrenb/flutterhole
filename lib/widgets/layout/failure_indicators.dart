import 'package:flutter/material.dart';
import 'package:flutterhole/core/models/failures.dart';

class CenteredFailureIndicator extends StatelessWidget {
  const CenteredFailureIndicator(
    this.failure, {
    Key key,
  }) : super(key: key);

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('${failure.message ?? 'unknown failure'}'),
    );
  }
}
