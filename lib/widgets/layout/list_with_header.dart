import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ListWithHeader extends StatelessWidget {
  const ListWithHeader({
    Key key,
    @required this.header,
    @required this.child,
  }) : super(key: key);

  /// Typically a [ListTile].
  final Widget header;

  /// Typically a [SliverList].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Container(
        color: Theme.of(context).secondaryHeaderColor,
        child: header,
      ),
      sliver: child,
    );
  }
}
