import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeCard extends HookWidget {
  const CodeCard(
    this.code, {
    Key? key,
    this.tappable = true,
    this.expanded = true,
    this.onTap,
  })  : assert(tappable || onTap != null),
        super(key: key);

  final String code;
  final bool tappable;
  final bool expanded;
  final VoidCallback? onTap;

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
            : (onTap != null ? onTap : null),
        child: SingleChildScrollView(
          scrollDirection: expand.value ? Axis.horizontal : Axis.vertical,
          // physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              code,
              style: GoogleFonts.firaMono(
                fontSize: 12.0,
                color: Colors.white,
              ),
              // softWrap: !expand.value,
              // softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
