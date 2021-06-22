import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const importThemes = null;

const preselectedColors = [
  Color(0xFF1B5E20),
  Color(0xFF913300),
  Color(0xFFF0D973),
  Color(0xFFC55530),
  Color(0xFF735031),
  Color(0xFF291504),
  Color(0xFF775A16),
  Color(0xFFBF7925),
  Color(0xFF909E5B),
  Color(0xFFD7BD6E),
  Color(0xFF54765F),
  Color(0xFF91C4A7),
  Color(0xFFE8D8D0),
  Color(0xFFD68A75),
  Color(0xFFC84A50),
  Color(0xFF266040),
  Color(0xFF57C986),
  Color(0xFFFAD58B),
  Color(0xFFF17F4E),
  Color(0xFFC84D3E),
];

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
    final c = Theme.of(context);
    final onPrimary = pi.primaryColor.computeForegroundColor();
    final onAccent = pi.accentColor.computeForegroundColor();
    return Theme(
      data: Theme.of(context).copyWith(
          // textTheme: Theme.of(context).textTheme.copyWith(
          //     bodyText1: TextStyle(
          //         color: Colors.green,
          //         )),
          primaryColor: pi.primaryColor,
          accentColor: pi.accentColor,
          toggleableActiveColor: pi.accentColor,
          buttonColor: onPrimary,
          colorScheme: c.colorScheme.copyWith(
            primary: pi.primaryColor,
            onPrimary: onPrimary,
            secondary: pi.accentColor,
            onSecondary: onAccent,
          ),
          checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateProperty.resolveWith((states) => onAccent),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.resolveWith((states) => pi.accentColor),
            ),
          ),
          primaryColorBrightness:
              onPrimary == Colors.white ? Brightness.dark : Brightness.light,
          primaryTextTheme: c.primaryTextTheme.apply(bodyColor: onPrimary),
          appBarTheme: c.appBarTheme.copyWith(
            backgroundColor: c.appBarTheme.backgroundColor,
            iconTheme: IconThemeData(color: onPrimary),
          )),

      // data: ThemeData.from(
      //     colorScheme: c.colorScheme.copyWith(
      //   primary: pi.primaryColor,
      //   onPrimary: Colors.green,
      // )).copyWith(
      //   primaryColor: pi.primaryColor,
      //   accentColor: pi.accentColor,
      //   primaryColorDark: Colors.pink,
      //   textSelectionTheme: c.textSelectionTheme.copyWith(
      //     cursorColor: pi.accentColor,
      //     selectionColor: pi.accentColor.withOpacity(.5),
      //     selectionHandleColor: pi.accentColor,
      //   ),
      //   toggleableActiveColor: pi.primaryColor,
      //   buttonColor: pi.primaryColor.computeForegroundColor(),
      //   appBarTheme: c.appBarTheme.copyWith(
      //     backgroundColor: pi.primaryColor,
      //     titleTextStyle: TextStyle(
      //       color: Colors.green,
      //     ),
      //   ),
      // ),
      child: child,
    );
  }
}

class ActivePiTheme extends HookWidget {
  const ActivePiTheme({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final active = useProvider(activePiProvider);
    return PiTheme(pi: active, child: child);
  }
}
