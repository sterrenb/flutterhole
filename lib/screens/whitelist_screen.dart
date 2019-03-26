import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/api/list_model.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/whitelist_view.dart';

class WhiteListScreen extends StatefulWidget {
  @override
  _WhiteListScreenState createState() => _WhiteListScreenState();
}

class _WhiteListScreenState extends State<WhiteListScreen> {
  final String title = 'Whitelist';
  final ListType type = ListType.white;

//  Future<bool> addNewDomain(BuildContext context, {String domain}) async {
//    final controller = TextEditingController();
//    if (domain == null) domain = await openListEditDialog(context, controller);
//
//    if (domain == null) return false;
//    if (view.model.lists.first.contains(domain)) {
//      showSnackBar(context, '$domain is already whitelisted');
//      return false;
//    }
//    showSnackBar(context, 'Adding $domain');
//    try {
//      setState(() {
//        view.model.add(domain);
//      });
//      return true;
//    } catch (e) {
//      showSnackBar(context, e.toString());
//    }
//
//    return false;
//  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
        title: title,
//      fab: FloatingActionButton(
////        onPressed: () => _addToList(context, domain: 'thomas.test'),
//        onPressed: () => addNewDomain(context).then((didSet) {
//              print(didSet);
////              if (didSet) view.model.add('testing');
//            }),
//        child: Icon(Icons.add),
//        tooltip: 'Whitelist a domain',
//      ),
        body: WhitelistView(
          model: WhiteListModel(),
        ));
  }
}