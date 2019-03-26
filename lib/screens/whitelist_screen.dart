import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sterrenburg.github.flutterhole/api/list_model.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/dismissible.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/snack_bar.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/edit_form.dart';

class WhiteListScreen extends StatefulWidget {
  @override
  _WhiteListScreenState createState() => _WhiteListScreenState();
}

class _WhiteListScreenState extends State<WhiteListScreen> {
  final String title = 'Whitelist';
  final ListType type = ListType.white;
  final WhitelistModel model = WhitelistModel();
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
    model.fetch().then((newList) {
      setState(() {
        localList = newList;
      });
    });
  }

  void addAgain(BuildContext context) async {
    final controller = TextEditingController();
    final String domain = await openListEditDialog(context, controller);
    if (domain == null) return;
    if (model.contains(domain)) {
      showSnackBar(context, '$domain already exists');
      return;
    }
    showSnackBar(context, 'Adding $domain');
    model
        .add(domain)
        .then((_) => update())
        .catchError((e) => showSnackBar(context, e.toString()));
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
        await model.remove(domain);
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
    final List<Widget> tiles = localList
        .map((domain) =>
        DismissibleListTile(domain: domain, onDismissed: _removeFromList))
        .toList();

    return DefaultScaffold(
        title: title,
        fab: Fab(addAgain),
        body: localList.length == 0
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Scrollbar(
            child: ListView(
                children:
                ListTile.divideTiles(context: context, tiles: tiles)
                    .toList())));
  }
}

class Fab extends FloatingActionButton {
  final Function(BuildContext context) callback;

  Fab(this.callback);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FloatingActionButton(
//        onPressed: () => _addToList(context, domain: 'thomas.test'),
      onPressed: () => callback(context),
      child: Icon(Icons.add),
      tooltip: 'Whitelist a domain',
    );
  }
}
