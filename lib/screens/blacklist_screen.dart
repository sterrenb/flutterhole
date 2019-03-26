import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:logging/logging.dart';
import 'package:sterrenburg.github.flutterhole/api/list_model.dart';
import 'package:sterrenburg.github.flutterhole/screens/settings_screen.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/dismissible.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/snack_bar.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/edit_form.dart';

class BlacklistScreen extends StatefulWidget {
  @override
  _BlacklistScreenState createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen> {
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

  /// Fetches the latest model snapshot and updates the state.
  void update() {
    model.fetch().then((newLists) {
      setState(() {
        localListExact = newLists[BlacklistType.exact.index];
        localListWildcard = newLists[BlacklistType.wildcard.index];
      });
    });
  }

  /// Cancels the remove action for the exact [domain].
  void undoExactRemove(String domain) {
    if (this.mounted)
      setState(() {
        if (!localListExact.contains(domain)) localListExact.add(domain);
      });
  }

  /// Cancels the remove action for the wildcard based on [domain].
  void undoWildcardRemove(String domain) {
    if (this.mounted)
      setState(() {
        if (!localListWildcard.contains(domain)) localListWildcard.add(domain);
      });
  }

  /// Removes the [domain] from the relevant list based on [subType].
  Future<void> removeFromList(BuildContext context, String domain,
      {ListType subType = ListType.black}) async {
    timer = Timer(defaultSnackBarDuration, () async {
      try {
        await model.remove(domain, subType: subType);
        log.info('removed $domain');
        if (this.mounted)
          setState(() {
            switch (subType) {
              case ListType.black:
                localListExact.remove(domain);
                break;
              case ListType.wild:
                localListWildcard.remove(domain);
                break;
              case ListType.regex:
                localListWildcard.remove(domain);
                break;
              default:
                return;
            }
          });
      } catch (e) {
        showSnackBar(context, e.toString());
        switch (subType) {
          case ListType.black:
            undoExactRemove(domain);
            break;
          case ListType.wild:
            undoWildcardRemove(domain);
            break;
          case ListType.regex:
            undoWildcardRemove(domain);
            break;
          default:
            return;
        }
      }
    });
    showSnackBar(context, 'Removed $domain',
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              timer.cancel();
              switch (subType) {
                case ListType.black:
                  undoExactRemove(domain);
                  break;
                case ListType.wild:
                  undoWildcardRemove(domain);
                  break;
                case ListType.regex:
                  undoWildcardRemove(domain);
                  break;
                default:
                  return;
              }
            }));
  }

  /// Prompts the user to enter a string, then adds it to the model.
  void add(BuildContext context, {ListType subType = ListType.black}) async {
    final controller = TextEditingController();
    String title = 'Enter a domain';
    if (subType == ListType.wild) title = 'Enter a wildcard';
    if (subType == ListType.regex) title = 'Enter a regex';
    final String domain = await openListEditDialog(context, controller, title);
    if (domain == null) return;
    if (model.contains(domain)) {
      showSnackBar(context, '$domain already exists');
      return;
    }
    showSnackBar(context, 'Adding $domain');
    model
        .add(domain, subType: subType)
        .then((_) => update())
        .catchError((e) => showSnackBar(context, e.toString()));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    final int entries = localListExact.length + localListWildcard.length;

    if (entries > 0) {
      tiles.add(ListTab('Exact blocking'));
      localListExact.sort();
      tiles.addAll(localListExact.map((String domain) =>
          DismissibleListTile(
            domain: domain,
            onDismissed: (BuildContext context, String domain) =>
                removeFromList(context, domain),
          )));

      tiles.add(ListTab('Regex & Wildcard blocking'));
      localListWildcard.sort();
      tiles.addAll(localListWildcard.map((String domain) =>
          DismissibleListTile(
            domain: domain,
            onDismissed: (BuildContext context, String domain) =>
                removeFromList(context, domain, subType: ListType.regex),
          )));
    }

    return DefaultScaffold(
        title: title,
        fab: BlacklistFab(add),
        body: Scrollbar(
            child: ListView(
                children: ListTile.divideTiles(context: context, tiles: tiles)
                    .toList())));
  }
}

/// The fab for the blacklist page.
///
/// This widget is extracted for the purpose of properly showing snack bars.
class BlacklistFab extends FloatingActionButton {
  final Function(BuildContext context, {ListType subType}) add;

  BlacklistFab(this.add);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      tooltip: 'Blacklist a domain',
      overlayColor: Theme
          .of(context)
          .canvasColor,
      children: [
        SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Exact',
            labelBackgroundColor: Colors.white,
            labelStyle: TextStyle(color: Colors.black),
            onTap: () => add(context)),
        SpeedDialChild(
            child: Icon(Icons.all_inclusive),
            label: 'Wildcard',
            labelBackgroundColor: Colors.white,
            labelStyle: TextStyle(color: Colors.black),
            onTap: () => add(context, subType: ListType.wild)),
        SpeedDialChild(
            child: Icon(Icons.code),
            label: 'Regex',
            labelBackgroundColor: Colors.white,
            labelStyle: TextStyle(color: Colors.black),
            onTap: () => add(context, subType: ListType.regex)),
      ],
    );
  }
}
