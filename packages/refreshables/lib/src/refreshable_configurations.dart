import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableWaterDropConfiguration extends StatelessWidget {
  const RefreshableWaterDropConfiguration({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      headerBuilder: () => WaterDropMaterialHeader(),
      child: child,
    );
  }
}
