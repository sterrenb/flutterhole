import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/about/logo_inspector.dart';
import 'package:flutterhole_web/features/layout/image_builders.dart';

class LogoIcon extends StatelessWidget {
  const LogoIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.0,
      child: Ink.image(
        image: const AssetImage('assets/icons/icon.png'),
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

class ThemedLogoImage extends StatelessWidget {
  const ThemedLogoImage({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ThemedImage(
      lightAssetName: 'assets/icons/logo_dark.png',
      darkAssetName: 'assets/icons/logo.png',
      width: width,
      height: height,
    );
  }
}
