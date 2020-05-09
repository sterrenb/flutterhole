import 'package:flutter/material.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/settings_bloc_builder.dart';

// Color to MaterialColor:
// https://medium.com/py-bits/turn-any-color-to-material-color-for-flutter-d8e8e037a837
Map<int, Color> _materialColorMap = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

class PiholeThemeBuilder extends StatelessWidget {
  const PiholeThemeBuilder({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SettingsBlocBuilder(
      builder: (BuildContext context, SettingsState state) {
        ThemeData data = Theme.of(context);

        if (state is SettingsStateSuccess) {
          data = data.copyWith(
            accentColor: MaterialColor(state.active.primaryColor.value, _materialColorMap),
          );
        }

        return Theme(
          data: data,
          child: child,
        );
      },
    );
  }
}
