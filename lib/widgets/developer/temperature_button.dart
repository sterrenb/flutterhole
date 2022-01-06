import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/drop_down_button_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TemperatureButton extends HookConsumerWidget {
  const TemperatureButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentReading = ref.watch(temperatureReadingProvider);
    return Center(
      child: ListTile(
        leading: const Icon(KIcons.temperatureReading),
        title: const Text('Temperature'),
        trailing: IconDropDownButtonBuilder<TemperatureReading>(
          value: currentReading,
          onChanged: (value) {
            ref
                .read(UserPreferencesNotifier.provider.notifier)
                .setTemperatureReading(value);
          },
          values: TemperatureReading.values,
          // icons: const [
          //   KIcons.developerMode,
          //   KIcons.info,
          //   KIcons.logWarning,
          //   // KIcons.logError,
          // ],
          builder: (context, reading) {
            return Text(Formatting.temperatureReadingToString(reading));
          },
        ),
      ),
    );
  }
}
