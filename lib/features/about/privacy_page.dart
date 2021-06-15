import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/layout/buttons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _markdownProvider = FutureProvider<String>((ref) async {
  return fetchPrivacyMarkdown();
});

class PrivacyPage extends HookWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markdownValue = useProvider(_markdownProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy'),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: Icon(KIcons.openUrl),
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
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
          error: (e, s) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(e.toString()),
                const SizedBox(height: 8.0),
                TryAgainButton(onTap: () {
                  context.refresh(_markdownProvider);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
