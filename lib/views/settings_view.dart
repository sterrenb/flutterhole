import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/api/ping_api_button.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/code_card.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/layout/list_title.dart';
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
            const _SettingsSection(
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
            _SettingsSection(
              title: "Pi-holes",
              children: [
                PiSelectList(
                  shrinkWrap: true,
                ),
                SizedBox(height: 20.0),
                PageWrap(
                  children: [
                    IconOutlinedButton(
                      iconData: KIcons.add,
                      onPressed: () {},
                      text: "New Pi-hole",
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
              ],
            ),
            const Divider(),
            _SettingsSection(title: "Danger zone", children: [
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
            ]),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTitle(title),
        ...children,
      ],
    );
  }
}
