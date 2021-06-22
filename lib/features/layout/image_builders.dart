import 'package:flutter/material.dart';

class ThemedImage extends StatelessWidget {
  const ThemedImage({
    Key? key,
    required this.lightAssetName,
    required this.darkAssetName,
    this.width,
    this.height,
  }) : super(key: key);

  final String lightAssetName;
  final String darkAssetName;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage(Theme.of(context).brightness == Brightness.light
          ? lightAssetName
          : darkAssetName),
      width: width,
      height: height,
    );
  }
}
