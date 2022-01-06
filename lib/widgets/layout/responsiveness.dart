import 'package:flutter/material.dart';
import 'package:flutterhole/widgets/layout/animations.dart';

extension BuildContextX on BuildContext {
  bool get isLight => Theme.of(this).brightness == Brightness.light;
}

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
    return Material(
      color: foregroundColor,
      // color: foregroundColor ?? Theme.of(context).scaffoldBackgroundColor,

      child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800.0,
          ),
          child: child),
    );
  }
}

typedef BreakpointBuilderCallback = Widget Function(
    BuildContext context, bool isBig);

class BreakpointBuilder extends StatelessWidget {
  const BreakpointBuilder({
    Key? key,
    required this.builder,
    this.bigBreakpoint = 800,
  }) : super(key: key);

  final BreakpointBuilderCallback builder;
  final double bigBreakpoint;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isBig = constraints.maxWidth > bigBreakpoint;
      return builder(context, isBig);
    });
  }
}

class LeftRightScaffold extends StatelessWidget {
  const LeftRightScaffold({
    Key? key,
    required this.title,
    required this.tabs,
    required this.left,
    required this.right,
    this.actions,
  })  : assert(tabs.length == 2),
        super(key: key);

  final Widget title;
  final List<Widget> tabs;
  final Widget left;
  final Widget right;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return BreakpointBuilder(builder: (context, isBig) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: title,
            bottom: isBig ? null : TabBar(tabs: tabs),
            actions: actions,
          ),
          body: AnimatedFader(
              child: isBig
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: left),
                        const RotatedBox(
                          quarterTurns: 1,
                          child: Divider(height: 0),
                        ),
                        Flexible(child: right),
                      ],
                    )
                  : TabBarView(
                      children: [
                        left,
                        right,
                      ],
                    )),
        ),
      );
    });
  }
}
