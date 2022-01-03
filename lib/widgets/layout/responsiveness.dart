import 'package:flutter/material.dart';

class MobileMaxWidth extends StatelessWidget {
  const MobileMaxWidth({
    Key? key,
    required this.child,
    this.center = true,
  }) : super(key: key);

  final Widget child;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
      child: center
          ? Center(
              child: _Content(child: child),
            )
          : _Content(child: child),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      constraints: const BoxConstraints(
        maxWidth: 800.0,
      ),
      child: child,
    );
  }
}

extension BuildContextX on BuildContext {
  bool get isLight => Theme.of(this).brightness == Brightness.light;
}
