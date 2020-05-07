import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';

class ActivePiholeTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      bloc: getIt<SettingsBloc>(),
      builder: (BuildContext context, SettingsState state) {
        return state.maybeWhen<Widget>(
          success: (all, active) {
            return Text('${active.title}');
          },
          orElse: () {
            return Text('$state');
          },
        );
      },
    );
  }
}
