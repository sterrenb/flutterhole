import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
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
        child: AppWrap(
          alignment: WrapAlignment.center,
          children: [
            IconOutlinedButton(
              iconData: KIcons.refresh,
              text: "Reset preferences",
              color: Theme.of(context).colorScheme.error,
              onPressed: () async {
                if (await showConfirmationDialog(context,
                        title: "Reset preferences?",
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "All preferences will be reset to the default value.",
                            ),
                            SizedBox(height: 8.0),
                            Text("Pi-hole configurations are unaffected."),
                          ],
                        )) ==
                    true) {
                  ref
                      .read(UserPreferencesNotifier.provider.notifier)
                      .clearPreferences();
                }
              },
            ),
            IconOutlinedButton(
              iconData: KIcons.delete,
              color: Theme.of(context).colorScheme.error,
              text: "Delete Pi-holes",
              onPressed: () async {
                if (await showConfirmationDialog(context,
                        title: "Delete Pi-holes?",
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "All Pi-hole configurations will be deleted.",
                            ),
                            SizedBox(height: 8.0),
                            Text("This action cannot be undone."),
                          ],
                        )) ==
                    true) {
                  ref
                      .read(UserPreferencesNotifier.provider.notifier)
                      .deletePiholes();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
