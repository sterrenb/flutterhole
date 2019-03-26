import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sterrenburg.github.flutterhole/api/list_model.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/snack_bar.dart';

class WhitelistView extends StatefulWidget {
  final WhiteListModel model;

  const WhitelistView({Key key, @required this.model}) : super(key: key);

  @override
  _WhitelistViewState createState() => _WhitelistViewState();
}

class _WhitelistViewState extends State<WhitelistView> {
  final log = Logger('Whitelist');
  List<String> localList;
  Timer timer;

  @override
  void initState() {
    super.initState();
    localList = [];
    update();
  }

  void update() {
    widget.model.fetch().then((newList) {
      setState(() {
        localList = newList;
      });
    });
  }

//  Future<void> addToList(BuildContext context, {String domain}) async {
//    final controller = TextEditingController();
//    if (domain == null) domain = await openListEditDialog(context, controller);
//
//    if (localList.contains(domain)) {
//      showSnackBar(context, '$domain is already whitelisted');
//      return;
//    }
//    showSnackBar(context, 'Adding $domain to whitelist');
//    try {
//      await widget.model.add(domain);
//      setState(() {
//        localList.add(domain);
//      });
//    } catch (e) {
//      showSnackBar(context, e.toString());
//    }
//  }

  void undoRemove(String domain) {
    if (this.mounted)
      setState(() {
        if (!localList.contains(domain)) localList.add(domain);
      });
  }

  Future<void> _removeFromList(BuildContext context, String domain) async {
    timer = Timer(defaultSnackBarDuration, () async {
      try {
        await widget.model.remove(domain);
        log.info('removed $domain');
        if (this.mounted)
          setState(() {
            localList.remove(domain);
          });
      } catch (e) {
        showSnackBar(context, e.toString());
        undoRemove(domain);
      }
    });
    showSnackBar(context, 'Removed $domain',
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              timer.cancel();
              undoRemove(domain);
            }));
  }

  @override
  Widget build(BuildContext context) {
    localList.sort();
    return localList.length == 0
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scrollbar(
            child: ListView(
            children: ListTile.divideTiles(
                context: context,
                tiles: localList.map((domain) => DismissibleListTile(
                    domain: domain, onDismissed: _removeFromList))).toList(),
          ));
  }
}

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
