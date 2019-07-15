import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/screen/pihole/pihole_edit_screen.dart';
import 'package:flutterhole_again/service/globals.dart';
import 'package:flutterhole_again/service/local_storage.dart';
import 'package:flutterhole_again/widget/dismissible_background.dart';
import 'package:flutterhole_again/widget/list_tab.dart';
import 'package:flutterhole_again/widget/pihole/pihole_button_row.dart';

class PiholeListBuilder extends StatefulWidget {
  final bool editable;

  const PiholeListBuilder({Key key, this.editable = true}) : super(key: key);

  @override
  _PiholeListBuilderState createState() => _PiholeListBuilderState();
}

class _PiholeListBuilderState extends State<PiholeListBuilder> {
  LocalStorage localStorage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    final instance = await LocalStorage.getInstance();
    setState(() {
      localStorage = instance;
    });
  }

  void _edit(Pihole pihole) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PiholeEditScreen(
              pihole: pihole,
            ),
      ),
    );
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
        shrinkWrap: true,
        itemCount: localStorage.cache.length,
        itemBuilder: (BuildContext context, int index) {
          final pihole =
          localStorage.cache[localStorage.cache.keys.elementAt(index)];
          final bool active = localStorage
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

  Future _activate(Pihole pihole, BuildContext context) async {
    await localStorage.activate(pihole);
    Globals.refresh(context);
    setState(() {});
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Changed to ${pihole.title}')));
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
    return ListTile(
      title: Text(pihole.title),
      subtitle: Text(pihole.baseUrl),
      trailing: Icon(Icons.keyboard_arrow_right),
      leading: Icon(Icons.check,
          color: active
              ? Theme.of(context).primaryColor
              : Colors.black.withOpacity(0.0)),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
