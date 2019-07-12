import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/dismissible_background.dart';

class RemovableTile extends StatefulWidget {
  final String title;
  final DismissDirectionCallback onDismissed;
  final GestureTapCallback onTap;

  const RemovableTile({
    Key key,
    @required this.title,
    this.onDismissed,
    this.onTap,
  }) : super(key: key);

  @override
  _RemovableTileState createState() => _RemovableTileState();
}

class _RemovableTileState extends State<RemovableTile> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.title),
      background: DismissibleBackground(),
      secondaryBackground:
          DismissibleBackground(alignment: Alignment.centerRight),
      onDismissed: widget.onDismissed,
      child: ListTile(
        title: Text(widget.title),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: widget.onTap,
//        onTap: () async {
//                          Globals.router
//                              .navigateTo(context, whitelistEditPath(domain));

//                          whitelistBloc.dispatch(EditOnWhitelist(
//                              original: domain,
//                              update: String.fromCharCodes(
//                                  domain.runes.toList().reversed)));
//        },
      ),
    );
  }
}
