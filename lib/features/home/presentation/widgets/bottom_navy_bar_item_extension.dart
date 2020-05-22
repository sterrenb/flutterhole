import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';

class BottomNavyBarItemExtension extends BottomNavyBarItem {
  final Key key;

  BottomNavyBarItemExtension({
    this.key,
    Icon icon,
    Text title,
    Color activeColor,
    Color inactiveColor,
    TextAlign textAlign,
  }) : super(
          icon: icon,
          title: title,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          textAlign: textAlign,
        );
}
