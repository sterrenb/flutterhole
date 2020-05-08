import 'package:flutter/material.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/routing/presentation/notifiers/drawer_notifier.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_settings_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/settings_bloc_builder.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsBlocBuilder(
        builder: (BuildContext context, SettingsState state) {
      return state.maybeWhen<Widget>(success: (all, active) {
        return Consumer<DrawerNotifier>(
            builder: (BuildContext context, DrawerNotifier notifier, _) {
          return AnimatedContainer(
            height: notifier.isExpanded
                ? kToolbarHeight * all.length +
                    (Theme.of(context).dividerTheme?.space ?? 16.0)
                : 0,
            curve: Curves.ease,
            duration: kThemeAnimationDuration,
            child: AnimatedOpacity(
              opacity: notifier.isExpanded ? 1 : 0,
              curve: Curves.ease,
              duration: kThemeAnimationDuration,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: all.length,
                      itemBuilder: (context, index) {
                        final settings = all.elementAt(index);
                        return PiholeSettingsTile(
                          settings: settings,
                          isActive: settings == active,
                          onTap: () {
                            getIt<SettingsBloc>()
                                .add(SettingsEvent.activate(settings));
                          },
                        );
                      }),
                  Divider(),
                ],
              ),
            ),
          );
        });
      }, orElse: () {
        return Container();
      });
    });
  }
}
