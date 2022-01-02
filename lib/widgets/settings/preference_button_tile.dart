import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PreferenceButtonTile extends HookConsumerWidget {
  const PreferenceButtonTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () async {
                ref.read(UserPreferencesNotifier.provider.notifier).reload();
              },
              child: Text("Reload"),
            ),
            ElevatedButton.icon(
              label: Text("Reset preferences"),
              icon: Icon(KIcons.refresh),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.error,
                onPrimary: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () async {
                if (await showConfirmationDialog(context,
                        title: "Reset preferences?",
                        body: Text(
                          "All preferences will be reset to the default value.",
                        )) ==
                    true) {
                  ref.read(UserPreferencesNotifier.provider.notifier).clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
