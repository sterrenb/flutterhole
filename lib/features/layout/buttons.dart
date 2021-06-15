import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';

class TryAgainButton extends StatelessWidget {
  const TryAgainButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(KIcons.refresh),
      label: Text('Try again'),
    );
  }
}
