import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
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
              text: 'Reset preferences',
              color: Theme.of(context).colorScheme.error,
              onPressed: () async {
                if (await showConfirmationDialog(context,
                        title: 'Reset preferences?',
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'All preferences will be reset to the default value.',
                            ),
                            SizedBox(height: 8.0),
                            Text('Pi-hole configurations are unaffected.'),
                          ],
                        )) ==
                    true) {
                  ref.resetPreferences(context);
                }
              },
            ),
            IconOutlinedButton(
              iconData: KIcons.delete,
              color: Theme.of(context).colorScheme.error,
              text: 'Delete Pi-holes',
              onPressed: () async {
                if (await showDeleteConfirmationDialog(
                      context,
                      'Delete all Pi-holes?',
                    ) ==
                    true) {
                  ref.deletePiholes(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
