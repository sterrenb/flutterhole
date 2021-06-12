import 'package:flutter/material.dart';
import 'package:flutterhole_web/entities.dart';

const importThemes = null;

extension ColorX on Color {
  Color computeForegroundColor([
    Color dark = Colors.black,
    Color light = Colors.white,
  ]) =>
      computeLuminance() > .5 ? dark : light;
}

class PiTheme extends StatelessWidget {
  const PiTheme({
    Key? key,
    required this.pi,
    required this.child,
  }) : super(key: key);

  final Pi pi;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: pi.primaryColor,
                onPrimary: Colors.green,
              )).copyWith(
          primaryColor: pi.primaryColor,
          accentColor: pi.accentColor,
          primaryColorDark: Colors.pink,
          textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
                cursorColor: pi.accentColor,
                selectionColor: pi.accentColor.withOpacity(.5),
                selectionHandleColor: pi.accentColor,
              )),
      child: child,
    );
  }
}
