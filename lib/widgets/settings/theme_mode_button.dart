import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/centered_leading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const themeModeIcons = {
  ThemeMode.system: KIcons.systemTheme,
  ThemeMode.light: KIcons.lightTheme,
  ThemeMode.dark: KIcons.darkTheme,
};

class ThemeModeButton extends HookConsumerWidget {
  const ThemeModeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final flexSchemeData = ref.watch(flexSchemeDataProvider);

    return Row(
      children: [
        Flexible(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CenteredLeading(
              child: Icon(themeModeIcons[themeMode]),
            ),
            title: const Text("Theme Mode"),
            subtitle:
                Text(Formatting.enumToString(themeMode).capitalizeFirstLetter),
          ),
        ),
        Expanded(
          child: FlexThemeModeSwitch(
            width: 16.0,
            height: 16.0,
            themeMode: themeMode,
            labelLight: '',
            labelDark: '',
            labelSystem: '',
            onThemeModeChanged: (value) {
              ref
                  .read(UserPreferencesNotifier.provider.notifier)
                  .setThemeMode(value);
            },
            title: Container(),
            flexSchemeData: flexSchemeData,
            buttonOrder: FlexThemeModeButtonOrder.lightSystemDark,
          ),
        ),
      ],
    );
  }
}
