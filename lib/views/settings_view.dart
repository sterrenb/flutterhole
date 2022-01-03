import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/api/ping_api_button.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/code_card.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/settings/pi_select_list.dart';
import 'package:flutterhole/widgets/settings/preference_button_tile.dart';
import 'package:flutterhole/widgets/settings/theme_popup_menu.dart';
import 'package:flutterhole/widgets/settings/update_frequency_button.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutterhole/widgets/developer/theme_showcase.dart';
import 'package:flutterhole/widgets/developer/dev_mode_button.dart';
import 'package:flutterhole/widgets/developer/log_level_button.dart';
import 'package:flutterhole/widgets/developer/temperature_button.dart';
import 'package:flutterhole/widgets/developer/theme_mode_button.dart';
import 'package:flutterhole/widgets/developer/theme_toggle_button.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: kIsWeb,
      ),
      body: MobileMaxWidth(
        child: ListView(
          children: [
            const PingApiButton(),
            const AppSection(
              title: "Customization",
              children: [
                ThemePopupMenu(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(title: ThemeModeButton()),
                ),
                TemperatureButton(),
                UpdateFrequencyButton(),
              ],
            ),
            const Divider(),
            AppSection(
              title: "Pi-holes",
              children: [
                const PiSelectList(
                  shrinkWrap: true,
                ),
                const SizedBox(height: 20.0),
                AppWrap(
                  children: [
                    IconOutlinedButton(
                      iconData: KIcons.add,
                      onPressed: () {},
                      text: "New Pi-hole",
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
              ],
            ),
            const Divider(),
            AppSection(title: "Danger zone", children: [
              const DevModeButton(),
              DevWidget(
                  child: Column(
                children: [
                  const LogLevelButton(),
                  const ThemeToggleButton(),
                  Row(
                    children: [
                      Expanded(
                        child: CodeCard(Formatting.jsonToCode(ref
                            .watch(UserPreferencesNotifier.provider)
                            .toJson())),
                      ),
                    ],
                  ),
                  const ThemeShowcaseButton(),
                ],
              )),
              const PreferenceButtonTile(),
              const SizedBox(height: 20.0),
            ]),
          ],
        ),
      ),
    );
  }
}
