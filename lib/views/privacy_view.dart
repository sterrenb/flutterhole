import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _markdownProvider = FutureProvider<String>((ref) async {
  return WebService.fetchPlainData(KUrls.privacyRawUrl);
});

class PrivacyView extends HookConsumerWidget {
  const PrivacyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markdownValue = ref.watch(_markdownProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(KIcons.openUrl),
            onPressed: () {
              WebService.launchUrlInBrowser(KUrls.privacyUrl);
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
    );
  }
}
