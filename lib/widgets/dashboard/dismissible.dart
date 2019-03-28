import 'package:flutter/material.dart';

class DismissibleListTile extends StatelessWidget {
  final String domain;
  final Function(BuildContext context, String domain) onDismissed;

  const DismissibleListTile({Key key, @required this.domain, this.onDismissed})
      : super(key: key);

  static int i = 0;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(domain + (++i).toString()),
      onDismissed: (direction) => onDismissed(context, domain),
      child: ListTile(
        title: Text(domain),
      ),
      background: DismissibleBackground(),
      secondaryBackground:
          DismissibleBackground(alignment: Alignment.centerRight),
    );
  }
}

class DismissibleBackground extends StatelessWidget {
  final AlignmentGeometry alignment;

  const DismissibleBackground({
    Key key,
    this.alignment = Alignment.centerLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
    );
  }
}
