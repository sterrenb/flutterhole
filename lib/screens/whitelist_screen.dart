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
  final WhitelistModel model = WhitelistModel();
  final log = Logger('Whitelist');
  List<String> localList;
  Timer timer;

  @override
  void initState() {
    super.initState();
    localList = [];
    _update();
  }

  /// Fetches the latest model snapshot and updates the state.
  void _update() {
    model.fetch().then((newList) {
      setState(() {
        localList = newList;
      });
    });
  }

  /// Prompts the user to enter a string, then adds it to the model.
  void _add(BuildContext context) async {
    final controller = TextEditingController();
    final String domain =
    await openListEditDialog(context, controller, 'Enter a domain');
    if (domain == null) return;
    if (model.contains(domain)) {
      showSnackBar(context, '$domain already exists');
      return;
    }
    showSnackBar(context, 'Adding $domain');
    model
        .add(domain)
        .then((_) => _update())
        .catchError((e) => showSnackBar(context, e.toString()));
  }

  /// Cancels the remove action for [domain].
  void _undoRemove(String domain) {
    if (this.mounted)
      setState(() {
        if (!localList.contains(domain)) localList.add(domain);
      });
  }

  /// Removes the [domain] from the relevant list.
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
        _undoRemove(domain);
      }
    });
    showSnackBar(context, 'Removed $domain',
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              timer.cancel();
              _undoRemove(domain);
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
        fab: _Fab(_add),
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

/// The fab for the whitelist page.
///
/// This widget is extracted for the purpose of properly showing snack bars.
class _Fab extends FloatingActionButton {
  final Function(BuildContext context) callback;

  _Fab(this.callback);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => callback(context),
      child: Icon(Icons.add),
      tooltip: 'Whitelist a domain',
    );
  }
}
