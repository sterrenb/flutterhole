import 'package:flutter/material.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/layout/dismissible_background.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';
import 'package:flutterhole/widget/pihole/pihole_button_row.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class PiholeListBuilder extends StatefulWidget {
  final bool editable;

  const PiholeListBuilder({Key key, this.editable = true}) : super(key: key);

  @override
  _PiholeListBuilderState createState() => _PiholeListBuilderState();
}

class _PiholeListBuilderState extends State<PiholeListBuilder> {
  final localStorage = Globals.localStorage;

  void _edit(Pihole pihole) async {
    final String message =
    await Globals.router.navigateTo(context, piholeEditPath(pihole));
    if (message != null) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future _activate(Pihole pihole, BuildContext context) async {
    await localStorage.activate(pihole);
    Globals.refresh();
    setState(() {});
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Changed to ${pihole.title}')));
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Center(child: CircularProgressIndicator());
    if (localStorage == null) {
      return body;
    }

    if (localStorage.cache.length == 0) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('No Piholes found.'),
        ],
      );
    }

    body = ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: localStorage.cache.length,
        itemBuilder: (BuildContext context, int index) {
          final pihole =
          localStorage.cache[localStorage.cache.keys.elementAt(index)];
          final bool active = localStorage.active() != null &&
              localStorage
                  .active()
                  .title == pihole.title;
          if (widget.editable) {
            return Dismissible(
              key: Key(pihole.title),
              onDismissed: (direction) async {
                final didRemove = await localStorage.remove(pihole);

                if (didRemove) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Removed ${pihole.title}'),
                    action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await localStorage.add(pihole);
                          setState(() {});
                        }),
                  ));
                  setState(() {});
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Could not remove ${pihole.title}')));
                }
              },
              background: DismissibleBackground(),
              secondaryBackground:
              DismissibleBackground(alignment: Alignment.centerRight),
              child: PiholeTile(
                pihole: pihole,
                active: active,
                onTap: () => _edit(pihole),
                onLongPress: () => _activate(pihole, context),
              ),
            );
          } else {
            return PiholeTile(
              pihole: pihole,
              active: active,
              onTap: () async {
                await _activate(pihole, context);
                Navigator.of(context).pop();
              },
//              onLongPress: () => _edit(pihole),
            );
          }
        });

    return Column(
      children: <Widget>[
        widget.editable ? Container() : ListTab('Select configuration'),
        widget.editable ? Container() : Divider(),
        body,
        Divider(),
        widget.editable
            ? PiholeButtonRow(
          localStorage: localStorage,
          onStateChange: () {
            setState(() {});
          },
        )
            : Container(),
      ],
    );
  }
}

class PiholeTile extends StatelessWidget {
  final Pihole pihole;
  final bool active;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  const PiholeTile(
      {Key key,
      @required this.pihole,
        this.active = false,
        this.onTap,
        this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);

    return ListTile(
      title: Text(pihole.title),
      subtitle: Text(pihole.basePath),
      trailing: Icon(Icons.keyboard_arrow_right),
      leading: Icon(Icons.check,
          color: active
              ? _theme.accentColor
//              ? Theme.of(context).primaryColor
              : Colors.black.withOpacity(0.0)),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
