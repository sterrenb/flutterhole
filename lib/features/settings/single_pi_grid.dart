import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';

class PiGridCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PiGridCard({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(kGridSpacing),
      ),
      child: GridInkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class DoublePiGridCard extends StatelessWidget {
  final Widget left;
  final Widget right;
  final VoidCallback? onTap;

  const DoublePiGridCard({
    Key? key,
    required this.left,
    required this.right,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PiGridCard(
      child: GridInkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: left,
            ),
            Expanded(
              child: right,
            ),
          ],
        ),
      ),
    );
  }
}

class TriplePiGridCard extends StatelessWidget {
  final Widget left;
  final Widget right;
  final Widget bottom;
  final VoidCallback? onTap;

  const TriplePiGridCard({
    Key? key,
    required this.left,
    required this.right,
    required this.bottom,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PiGridCard(
      child: GridInkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: left,
                  ),
                  Expanded(
                    child: right,
                  ),
                ],
              ),
            ),
            Expanded(
              child: bottom,
            ),
          ],
        ),
      ),
    );
  }
}
