import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO cache fonts
final mono = GoogleFonts.firaMono(
  fontSize: 12.0,
  color: Colors.white,
);

class _CodeText extends StatelessWidget {
  const _CodeText({
    Key? key,
    required this.code,
    required this.singleLine,
  }) : super(key: key);

  final String code;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    return Text(
      code,
      style: mono,
      overflow: TextOverflow.fade,
      maxLines: 10,
      softWrap: !singleLine,
    );
  }
}

class _SelectableCodeText extends StatelessWidget {
  const _SelectableCodeText(this.code, {Key? key}) : super(key: key);

  final String code;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      code,
      style: mono,
    );
  }
}

class CodeCard extends StatelessWidget {
  const CodeCard({
    Key? key,
    required this.code,
    this.onTap,
    this.singleLine = false,
  }) : super(key: key);

  final String code;
  final VoidCallback? onTap;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: KColors.code,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kGridSpacing)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _CodeText(
            code: code,
            singleLine: singleLine,
          ),
        ),
      ),
    );
  }
}

class SelectableCodeCard extends StatelessWidget {
  const SelectableCodeCard(
    this.code, {
    Key? key,
    this.onTap,
  }) : super(key: key);

  final String code;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: KColors.code,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kGridSpacing)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _SelectableCodeText(code),
        ),
      ),
    );
  }
}

class ExpandableCode extends HookWidget {
  const ExpandableCode({
    Key? key,
    required this.code,
    this.singleLine = false,
    this.tappable = true,
    this.expanded = false,
    this.onTap,
  }) : super(key: key);

  final String code;
  final bool tappable;
  final bool expanded;
  final VoidCallback? onTap;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final expand = useState(expanded);
    return Card(
      elevation: 0.0,
      color: Colors.grey[850],
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        onTap: tappable
            ? () {
                expand.value = !expand.value;
              }
            : (onTap),
        child: SingleChildScrollView(
          scrollDirection: expand.value ? Axis.horizontal : Axis.vertical,
          // physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _CodeText(
              code: code,
              singleLine: singleLine,
            ),
          ),
        ),
      ),
    );
  }
}
