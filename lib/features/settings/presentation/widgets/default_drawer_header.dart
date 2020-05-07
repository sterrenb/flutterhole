import 'package:flutter/material.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/active_pihole_title.dart';
import 'package:flutterhole/features/settings/presentation/widgets/settings_bloc_builder.dart';

class PiholeCircleAvatar extends StatelessWidget {
  const PiholeCircleAvatar(
    this.settings, {
    Key key,
    this.onTap,
  }) : super(key: key);

  final PiholeSettings settings;
  final VoidCallback onTap;

  Color get _primaryColor {
    int index = settings.title.length;

    final debugIndex = settings.title.indexOf('#');
    if (debugIndex >= 0) {
      index = debugIndex;
    }

    return Colors.primaries.elementAt(index % Colors.primaries.length);
  }

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
          backgroundColor: _primaryColor,
//          backgroundColor: Theme.of(context).colorScheme.surface,
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
          success: (all, active) {
            return List<Widget>.generate(all.length, (int index) {
              final settings = all.elementAt(index);
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
      );
    });
  }
}
