import 'package:flutter/material.dart';

import 'animations.dart';

class CenteredLeading extends StatelessWidget {
  const CenteredLeading({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [child],
    );
  }
}
