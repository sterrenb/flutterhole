import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeCard extends HookWidget {
  const CodeCard(
    this.code, {
    Key? key,
    this.tappable = true,
  }) : super(key: key);

  final String code;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final expand = useState(true);
    return Card(
      elevation: 0.0,
      color: Colors.grey[850],
      child: InkWell(
        onTap: tappable
            ? () {
                expand.value = !expand.value;
                print(expand.value);
              }
            : null,
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
