import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO cache fonts
final mono = GoogleFonts.firaMono(
    // fontSize: 12.0,
    // color: Colors.white,
    );

class CodeCard extends HookConsumerWidget {
  const CodeCard(this.text, {Key? key, this.maxLines}) : super(key: key);

  final String text;
  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: ref.watch(darkThemeProvider),
      child: Card(
        // color: Theme.of(context).backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SelectableText(
            text,
            style: mono,
            maxLines: maxLines,
          ),
        ),
      ),
    );
  }
}
