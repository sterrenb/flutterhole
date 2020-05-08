import 'package:flutter/material.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/routing/presentation/notifiers/drawer_notifier.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/active_pihole_title.dart';
import 'package:flutterhole/features/settings/presentation/widgets/settings_bloc_builder.dart';
import 'package:provider/provider.dart';

class PiholeCircleAvatar extends StatelessWidget {
  const PiholeCircleAvatar(
    this.settings, {
    Key key,
    this.onTap,
  }) : super(key: key);

  final PiholeSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        CircleAvatar(
          child: Text(
            '${settings.title?.substring(0, 2) ?? ''}',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
          ),
          backgroundColor:
              settings.primaryColor ?? Theme.of(context).colorScheme.surface,
        ),
        ClipOval(
          child: Tooltip(
            message: '${settings.title}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Theme.of(context)
                    .primaryTextTheme
                    .headline6
                    .color
                    .withOpacity(0.2),
                onTap: onTap ?? () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DefaultDrawerHeader extends StatelessWidget {
  const DefaultDrawerHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsBlocBuilder(
        builder: (BuildContext context, SettingsState state) {
      return UserAccountsDrawerHeader(
        accountName: ActivePiholeTitle(),
        accountEmail: null,
        currentAccountPicture: state.maybeWhen<Widget>(
          success: (all, active) => PiholeCircleAvatar(active),
          orElse: () => null,
        ),
        otherAccountsPictures: state.maybeWhen<List<Widget>>(
          success: (all, PiholeSettings active) {
            final some = List<PiholeSettings>.from(all)..remove(active);
            return List<Widget>.generate(some.length, (int index) {
              final settings = some.elementAt(index);
              return PiholeCircleAvatar(
                settings,
                onTap: () {
                  getIt<SettingsBloc>().add(SettingsEvent.activate(settings));
                },
              );
            });
          },
          orElse: () => null,
        ),
        onDetailsPressed: state.maybeWhen<VoidCallback>(
            success: (_, __) => () {
                  Provider.of<DrawerNotifier>(
                    context,
                    listen: false,
                  ).toggle();
                },
            orElse: () => null),
      );
    });
  }
}
