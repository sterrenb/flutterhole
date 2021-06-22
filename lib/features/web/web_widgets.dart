import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NoWebBuilder extends StatelessWidget {
  const NoWebBuilder({
    Key? key,
    required this.child,
    this.orElse,
  }) : super(key: key);

  final Widget child;
  final Widget? orElse;

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? orElse ??
            Center(child: Text('This widget is not supported on the web.'))
        : child;
  }
}
