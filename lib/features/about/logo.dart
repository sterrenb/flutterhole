import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/query_log/logo_inspector.dart';

class LogoIcon extends StatelessWidget {
  const LogoIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.0,
      child: Ink.image(
        image: AssetImage('assets/icons/icon.png'),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (sheetContext) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  return LogoInspector(screenWidth: screenWidth);
                  // return LogoInspector(screenWidth: screenWidth);
                });
          },
        ),
      ),
    );
  }
}
