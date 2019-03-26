import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sterrenburg.github.flutterhole/api/list_model.dart';
import 'package:sterrenburg.github.flutterhole/screens/settings_screen.dart';
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

  void add(BuildContext context) async {
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
        fab: Fab(add),
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

class BLScreen extends StatefulWidget {
  @override
  _BLScreenState createState() => _BLScreenState();
}

class _BLScreenState extends State<BLScreen> {
  final String title = 'Blacklist';
  final BlacklistModel model = BlacklistModel();
  final log = Logger('Blacklist');
  Timer timer;

  List<String> localListExact, localListWildcard;

  @override
  void initState() {
    super.initState();
    localListExact = localListWildcard = [];
    update();
  }

  void update() {
    model.fetch().then((newLists) {
      setState(() {
        localListExact = newLists[BlacklistType.exact.index];
        localListWildcard = newLists[BlacklistType.wildcard.index];
      });
    });
  }

  void undoExactRemove(String domain) {
    if (this.mounted)
      setState(() {
        if (!localListExact.contains(domain)) localListExact.add(domain);
      });
  }

  void undoWildcardRemove(String domain) {
    if (this.mounted)
      setState(() {
        if (!localListWildcard.contains(domain)) localListWildcard.add(domain);
      });
  }

  Future<void> removeFromList(BuildContext context, String domain,
      {bool isRegex = false}) async {
    timer = Timer(defaultSnackBarDuration, () async {
      try {
        await model.remove(domain, isRegex: isRegex);
        log.info('removed $domain');
        if (this.mounted)
          setState(() {
            if (isRegex) {
              localListWildcard.remove(domain);
            } else {
              localListExact.remove(domain);
            }
          });
      } catch (e) {
        showSnackBar(context, e.toString());
        if (isRegex) {
          undoWildcardRemove(domain);
        } else {
          undoExactRemove(domain);
        }
      }
    });
    showSnackBar(context, 'Removed $domain',
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              timer.cancel();
              if (isRegex) {
                undoWildcardRemove(domain);
              } else {
                undoExactRemove(domain);
              }
            }));
  }

  void add(BuildContext context, {bool isRegex = false}) async {
    final controller = TextEditingController();
    final String domain = await openListEditDialog(context, controller);
    if (domain == null) return;
    if (model.contains(domain)) {
      showSnackBar(context, '$domain already exists');
      return;
    }
    showSnackBar(context, 'Adding $domain');
    model
        .add(domain, isRegex: isRegex)
        .then((_) => update())
        .catchError((e) => showSnackBar(context, e.toString()));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    final int entries = localListExact.length + localListWildcard.length;

    if (entries > 0) {
      tiles.add(ListTab('Exact blocking'));

      tiles.addAll(localListExact.map((String domain) =>
          DismissibleListTile(
            domain: domain,
            onDismissed: (BuildContext context, String domain) =>
                removeFromList(context, domain),
          )));

      tiles.add(ListTab('Regex & Wildcard blocking'));

      tiles.addAll(localListWildcard.map((String domain) =>
          DismissibleListTile(
            domain: domain,
            onDismissed: (BuildContext context, String domain) =>
                removeFromList(context, domain, isRegex: true),
          )));
    }

    return DefaultScaffold(
        title: title,
        fab: Fab(add),
        body: Scrollbar(
            child: ListView(
                children: ListTile.divideTiles(context: context, tiles: tiles)
                    .toList())));
  }
}

class Fab extends FloatingActionButton {
  final Function(BuildContext context) callback;

  Fab(this.callback);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => callback(context),
      child: Icon(Icons.add),
      tooltip: 'Whitelist a domain',
    );
  }
}
