import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/api/api_provider.dart';
import 'package:sterrenburg.github.flutterhole/screens/settings_screen.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/snack_bar.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/edit_form.dart';

class BlackListScreen extends StatefulWidget {
  final String title;
  final ListType type = ListType.black;

  const BlackListScreen({Key key, this.title}) : super(key: key);

  @override
  BlackListScreenState createState() => BlackListScreenState();
}

class BlackListScreenState extends State<BlackListScreen> {
  List<String> listExact, listWild;
  bool isAuthorized = false;

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  void fetchList() {
    ApiProvider().fetchList(widget.type).then((newList) {
      setState(() {
        listExact = newList[0];
        listWild = newList[1];
      });
    });
  }

  List<Widget> _addSubList(String title, List<Widget> widgets,
      List<String> entries) {
    widgets.add(ListTab(title));
    entries == null || entries.length == 0
        ? widgets.add(ListTile(
      title: Text(
        'No entries',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ))
        : widgets.addAll(entries.map((str) =>
        ListTile(
          title: Text(str),
        )));

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
//    list.sort();

    List<Widget> widgets = [];
    widgets = _addSubList('Exact blocking', widgets, listExact);
    widgets = _addSubList('Regex & Wildcard blocking', widgets, listWild);

    return DefaultScaffold(
      title: widget.title,
      fab: FloatingActionButton(
//        onPressed: () => _addToList(context),
        onPressed: null,
        child: Icon(Icons.add),
        tooltip: 'Blacklist a domain',
      ),
      body: ListView(
        children: widgets,
      ),
    );
  }
}
