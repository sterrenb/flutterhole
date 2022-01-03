import 'package:flutter/material.dart';

class LogoIcon extends StatelessWidget {
  const LogoIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.0,
      child: Ink.image(
        image: const AssetImage('assets/icon/icon.png'),
        child: InkWell(
          onTap: () {
            // showModalBottomSheet(
            //     context: context,
            //     builder: (sheetContext) {
            //       final screenWidth = MediaQuery.of(context).size.width;
            //       return LogoInspector(screenWidth: screenWidth);
            //       // return LogoInspector(screenWidth: screenWidth);
            //     });
          },
        ),
      ),
    );
  }
}
