import 'package:flutter/material.dart';

const importMediaQueries = null;

extension PortraitWidget on StatelessWidget {}

extension BuildContextX on BuildContext {
  MediaQueryData get _data => MediaQuery.of(this);

  bool get isLandscape => _data.orientation == Orientation.landscape;

  /// 1/3rd width in landscape
  EdgeInsets get clampedBodyPadding => EdgeInsets.symmetric(
      horizontal: isLandscape ? _data.size.width / 5 : 0.0);

  /// 2/3rd height in portrait
  EdgeInsets get clampedListPadding => EdgeInsets.symmetric(
      vertical: isLandscape ? 0.0 : _data.size.width / ((3 / 2) * 2));

  EdgeInsets get dialogPadding => EdgeInsets.all(24.0)
    ..add(this.clampedBodyPadding)
    ..add(this.clampedListPadding);
}
