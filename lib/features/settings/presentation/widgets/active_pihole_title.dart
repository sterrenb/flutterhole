import 'package:flutter/material.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/pi_connection_status_icon.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/settings_bloc_builder.dart';

class ActivePiholeTitle extends StatelessWidget {
  final bool interactive;

  const ActivePiholeTitle({
    Key key,
    this.interactive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SettingsBlocBuilder(
            builder: (BuildContext context, SettingsState state) {
              return state.maybeWhen<Widget>(
                success: (all, active) {
                  return Text('${active.title}');
                },
                orElse: () {
                  return Text('FlutterHole');
                },
              );
            }),
        PiConnectionStatusIcon(interactive: interactive),
      ],
    );
  }
}
