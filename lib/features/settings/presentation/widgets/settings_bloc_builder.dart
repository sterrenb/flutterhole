import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/presentation/blocs/settings_bloc.dart';

class SettingsBlocBuilder extends StatelessWidget {
  const SettingsBlocBuilder({
    @required this.builder,
    Key key,
  }) : super(key: key);

  final BlocWidgetBuilder<SettingsState> builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      bloc: getIt<SettingsBloc>(),
      condition: (SettingsState previous, SettingsState next) {
        if (previous is SettingsStateSuccess) return false;

        return true;
      },
      builder: builder,
    );
  }
}
