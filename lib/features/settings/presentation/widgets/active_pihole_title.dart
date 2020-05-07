import 'package:flutter/material.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:flutterhole/features/settings/presentation/widgets/settings_bloc_builder.dart';

class ActivePiholeTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsBlocBuilder(
        builder: (BuildContext context, SettingsState state) {
      return state.maybeWhen<Widget>(
        success: (all, active) {
          return Text('${active.title}');
        },
        orElse: () {
          return Text('$state');
        },
      );
    });
  }
}
