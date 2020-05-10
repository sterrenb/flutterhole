import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CenteredLoadingIndicator extends StatelessWidget {
  const CenteredLoadingIndicator({Key key, this.color}) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SpinKitFadingFour(
      color: color ?? Theme.of(context).accentColor,
    ));
  }
}

class LoadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitRipple(
      size: 24.0,
      color: Theme.of(context).accentColor,
    );
  }
}
