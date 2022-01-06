import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/drop_down_button_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LogLevelButton extends HookConsumerWidget {
  const LogLevelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logLevel = ref.watch(logLevelProvider);
    return Center(
      child: ListTile(
        leading: const Icon(KIcons.developerMode),
        title: const Text('Log level'),
        trailing: IconDropDownButtonBuilder<LogLevel>(
          value: logLevel,
          onChanged: (value) {
            ref
                .read(UserPreferencesNotifier.provider.notifier)
                .setLogLevel(value);
          },
          values: LogLevel.values,
          icons: const [
            KIcons.developerMode,
            KIcons.info,
            KIcons.logWarning,
            KIcons.logError,
          ],
          builder: (context, level) {
            return Text(Formatting.logLevelToString(level));
          },
        ),
      ),
    );
  }
}
