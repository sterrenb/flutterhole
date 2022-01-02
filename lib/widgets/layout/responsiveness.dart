import 'package:flutter/material.dart';

class MobileMaxWidth extends StatelessWidget {
  const MobileMaxWidth({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
      child: Center(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          constraints: BoxConstraints(
            maxWidth: 800.0,
          ),
          child: child,
        ),
      ),
    );
  }
}
