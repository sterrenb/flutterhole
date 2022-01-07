import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/about_view.dart';
import 'package:flutterhole/views/base_view.dart';
import 'package:flutterhole/views/single_pi_edit_view.dart';
import 'package:flutterhole/widgets/developer/dev_mode_button.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/developer/log_level_button.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/settings/temperature_button.dart';
import 'package:flutterhole/widgets/settings/theme_mode_button.dart';
import 'package:flutterhole/widgets/developer/theme_showcase.dart';
import 'package:flutterhole/widgets/developer/theme_toggle_button.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/onboarding/introduction_button.dart';
import 'package:flutterhole/widgets/settings/pi_select_list.dart';
import 'package:flutterhole/widgets/settings/preference_button_tile.dart';
import 'package:flutterhole/widgets/settings/theme_popup_menu.dart';
import 'package:flutterhole/widgets/settings/update_frequency_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseView(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: const [
            DevToolBar(),
          ],
        ),
        body: MobileMaxWidth(
          child: ListView(
            children: [
              const AppSection(
                title: 'Customization',
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
              const _MyPiholesSection(),
              const Divider(),
              AppSection(title: 'Other', children: [
                const ShowIntroductionListTile(),
                ListTile(
                  title: const Text('About'),
                  trailing: const Icon(KIcons.openDialog),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AboutView()));
                  },
                ),
                const _DeveloperSection(),
                const PreferenceButtonTile(),
                const SizedBox(height: 20.0),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPiholesSection extends HookConsumerWidget {
  const _MyPiholesSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSection(
      title: 'My Pi-holes',
      children: [
        const PiSelectList(
          shrinkWrap: true,
          max: 3,
        ),
        const SizedBox(height: 20.0),
        AppWrap(
          children: [
            OutlinedButton.icon(
              icon: const Icon(KIcons.add),
              onPressed: () {
                final pis = ref.read(allPiholesProvider);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProviderScope(overrides: [
                    piProvider
                        .overrideWithValue(Pi(title: 'Pi-hole #${pis.length}')),
                  ], child: const SinglePiEditView(isNew: true)),
                  fullscreenDialog: true,
                ));
              },
              label: const Text('New Pi-hole'),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}

class _DeveloperSection extends HookConsumerWidget {
  const _DeveloperSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(devModeProvider);
    final isDev = ref.watch(isDevProvider);

    return Visibility(
      visible: isDev,
      child: Column(
        children: [
          const DevModeButton(),
          DefaultAnimatedSize(
            child: devMode
                ? Column(
                    children: const [
                      LogLevelButton(),
                      ShowThemeToggleButton(),
                      if (kDebugMode) ...[ThemeShowcaseButton()],
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
