import 'package:flutter/material.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
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
  /// Applies theme data from the active [PiholeSettings].
  ///
  /// Optionally applies theme data from [settings].
  const PiholeThemeBuilder({
    Key key,
    @required this.child,
    this.settings,
  }) : super(key: key);

  final Widget child;
  final PiholeSettings settings;

  @override
  Widget build(BuildContext context) {
    if (settings != null) {
      return Theme(
        data: _buildTheme(context, settings),
        child: child,
      );
    }

    return SettingsBlocBuilder(
      builder: (BuildContext context, SettingsState state) {
        return state.maybeWhen<Widget>(
          success: (all, active) => Theme(
            data: _buildTheme(context, active),
            child: child,
          ),
          orElse: () => child,
        );
      },
    );
  }

  ThemeData _buildTheme(BuildContext context, PiholeSettings settings) {

    return Theme.of(context).copyWith(
      accentColor:
          MaterialColor(settings.primaryColor.value, _materialColorMap),
    );
  }
}
