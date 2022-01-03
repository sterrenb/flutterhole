import 'package:flutter/material.dart';

class MobileMaxWidth extends StatelessWidget {
  const MobileMaxWidth({
    Key? key,
    required this.child,
    this.center = true,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(key: key);

  final Widget child;
  final bool center;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ??
          Theme.of(context).colorScheme.secondary.withOpacity(.1),
      child: center
          ? Center(
              child: _Content(
                child: child,
                foregroundColor: foregroundColor,
              ),
            )
          : _Content(
              child: child,
              foregroundColor: foregroundColor,
            ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.child,
    this.foregroundColor,
  }) : super(key: key);

  final Widget child;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: foregroundColor ?? Theme.of(context).scaffoldBackgroundColor,
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
