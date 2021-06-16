import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';

const importDashTiles = null;

const Color kDashTileColor = Colors.white;

extension ThemeDataX on ThemeData {
  TextStyle get summaryStyle => textTheme.headline4!.copyWith(
        fontWeight: FontWeight.bold,
        color: kDashTileColor,
      );
}

class _SquareContainer extends StatelessWidget {
  const _SquareContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      // color: Colors.orange,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: child,
      ),
    );
  }
}

class WideNumberTile extends StatelessWidget {
  const WideNumberTile({
    Key? key,
    required this.iconData,
    required this.child,
    required this.isLoading,
    this.foregroundColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  final IconData iconData;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Widget child;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GridCard(
      color: backgroundColor,
      child: GridInkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SquareContainer(
                child: Icon(
              iconData,
              size: 32.0,
              color: foregroundColor?.withOpacity(.5),
            )),
            Expanded(child: child),
            _SquareContainer(
                child: Center(
                    child: Container(
              height: 24.0,
              width: 24.0,
              child: AnimatedOpacity(
                duration: kThemeAnimationDuration,
                opacity: isLoading ? 0.5 : 0.0,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  // strokeWidth: 10.0,
                ),
              ),
            ))),
          ],
        ),
      ),
    );
  }
}

class SquareNumberTile extends StatelessWidget {
  const SquareNumberTile({
    Key? key,
    required this.iconData,
    required this.child,
    required this.isLoading,
    this.foregroundColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  final IconData iconData;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Widget child;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GridCard(
      color: backgroundColor,
      child: GridInkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SquareContainer(
                child: Icon(
              iconData,
              size: 32.0,
              color: foregroundColor?.withOpacity(.5),
            )),
            Expanded(child: child),
            _SquareContainer(
                child: Center(
                    child: Container(
              height: 24.0,
              width: 24.0,
              child: AnimatedOpacity(
                duration: kThemeAnimationDuration,
                opacity: isLoading ? 0.5 : 0.0,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  // strokeWidth: 10.0,
                ),
              ),
            ))),
          ],
        ),
      ),
    );
  }
}
