import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/layout/error_builders.dart';
import 'package:flutterhole_web/features/settings/themes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _markdownProvider = FutureProvider<String>((ref) async {
  return fetchPrivacyMarkdown();
});

class PrivacyPage extends HookWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markdownValue = useProvider(_markdownProvider);
    return ActivePiTheme(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy'),
          actions: [
            IconButton(
              tooltip: 'Open in browser',
              icon: const Icon(KIcons.openUrl),
              onPressed: () {
                launchUrl(KUrls.privacyUrl);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: markdownValue.when(
            data: (markdown) => Markdown(
              physics: const BouncingScrollPhysics(),
              data: markdown,
              selectable: true,
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, s) => CenteredErrorMessage(e, s),
          ),
        ),
      ),
    );
  }
}
