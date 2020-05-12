import 'package:animations/animations.dart';
import 'package:flutterhole/features/settings/presentation/pages/add_pihole_page.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/pages/single_pihole_settings_page.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_settings_tile.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/features/settings/presentation/widgets/settings_bloc_builder.dart';
import 'package:flutterhole/widgets/layout/animated_opener.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/snackbars.dart';

// https://github.com/flutter/packages/blob/ed004de397e3823f2d986ac28a180baf683735ef/packages/animations/example/lib/container_transition.dart#L39
const double _fabDimension = 56.0;

enum _PopupOption {
  createDefault,
  reloadAll,
  deleteAll,
}

class _PopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PopupOption>(
      onSelected: (option) async {
        print(option);

        switch (option) {
          case _PopupOption.createDefault:
            getIt<SettingsBloc>().add(SettingsEventCreate());
            showInfoSnackBar(context, 'Created default Pihole',
                duration: Duration(seconds: 2));
            break;
          case _PopupOption.reloadAll:
            getIt<SettingsBloc>().add(SettingsEventInit());
            showInfoSnackBar(context, 'Reloaded from disk',
                duration: Duration(seconds: 2));
            break;
          case _PopupOption.deleteAll:
            final bool didConfirm = await showConfirmationDialog(
              context,
              title: Text('Delete all configurations? This cannot be undone.'),
            );

            if (didConfirm ?? false) {
              getIt<SettingsBloc>().add(SettingsEventReset());
              showInfoSnackBar(context, 'Deleted all configurations',
                  duration: Duration(seconds: 2));
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_PopupOption>>[
        const PopupMenuItem(
          child: Text('Create default Pihole'),
          value: _PopupOption.createDefault,
        ),
        const PopupMenuItem(
          child: Text('Reload from disk'),
          value: _PopupOption.reloadAll,
        ),
        const PopupMenuItem(
          child: Text('Delete all configurations'),
          value: _PopupOption.deleteAll,
        ),
      ],
    );
  }
}

class AllPiholeSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PiholeThemeBuilder(child: SettingsBlocBuilder(
        builder: (BuildContext context, SettingsState state) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Piholes'),
          actions: <Widget>[
            _PopupMenu(),
          ],
        ),
        floatingActionButton: _AddPiholeButton(),
        body: state.maybeWhen(
          success: (all, active) {
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: all.length,
                itemBuilder: (context, index) {
                  final settings = all.elementAt(index);
                  return AnimatedOpener(
                    closed: (context) => PiholeSettingsTile(
                      settings: settings,
                      isActive: settings == active,
                    ),
                    opened: (context) =>
                        SinglePiholeSettingsPage(initialValue: settings),
                    onLongPress: () {
                      getIt<SettingsBloc>()
                          .add(SettingsEvent.activate(settings));
                    },
                  );
                });
          },
          orElse: () {
            return Center(
              child: Text('${state}'),
            );
          },
        ),
      );
    }));
  }
}

class _AddPiholeButton extends StatelessWidget {
  const _AddPiholeButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openBuilder: (openContext, _) {
        return AddPiholePage();
      },
      tappable: false,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(_fabDimension / 2),
        ),
      ),
      openColor: Theme.of(context).accentColor,
      closedColor: Theme.of(context).accentColor,
      closedBuilder: (context, VoidCallback openContainer) {
        return Tooltip(
          message: 'Add Pihole',
          child: InkWell(
            onTap: openContainer,
            child: SizedBox(
              height: _fabDimension,
              width: _fabDimension,
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
