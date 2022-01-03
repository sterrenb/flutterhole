import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemePopupMenu extends HookConsumerWidget {
  const ThemePopupMenu({Key? key}) : super(key: key);

  static const schemes = FlexColor.schemes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usedSchemeData = ref.watch(flexSchemeDataProvider);
    return PopupMenuButton<FlexScheme>(
      tooltip: "Select theme",
      onSelected: (value) {
        ref
            .read(UserPreferencesNotifier.provider.notifier)
            .setFlexScheme(value);
      },
      child: Tooltip(
        message: kIsWeb ? "" : usedSchemeData.description,
        showDuration: const Duration(seconds: 3),
        child: ListTile(
          leading: const Icon(KIcons.theme),
          title: const Text("Theme"),
          subtitle: Text(usedSchemeData.name),
          trailing: PrimaryColorIcon(flexSchemeData: usedSchemeData),
        ),
      ),
      itemBuilder: (BuildContext context) {
        return schemes.entries
            .map((e) => PopupMenuItem<FlexScheme>(
                  value: e.key,
                  child: ListTile(
                    leading: PrimaryColorIcon(flexSchemeData: e.value),
                    trailing: (usedSchemeData.name == e.value.name)
                        ? const Icon(KIcons.selected)
                        : null,
                    title: Text(e.value.name),
                  ),
                ))
            .toList();
      },
    );
  }
}

class PrimaryColorIcon extends StatelessWidget {
  const PrimaryColorIcon({
    Key? key,
    required this.flexSchemeData,
  }) : super(key: key);

  final FlexSchemeData flexSchemeData;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Icon(
      Icons.lens,
      color:
          isLight ? flexSchemeData.light.primary : flexSchemeData.dark.primary,
      size: 36,
    );
  }
}
