import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/api/api_provider.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/snack_bar.dart';

class ListScreen extends StatefulWidget {
  final String title;
  final ListType type;

  const ListScreen({Key key, @required this.type, this.title})
      : super(key: key);

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  List<String> list = [];

  @override
  void initState() {
    super.initState();
    ApiProvider().fetchList(widget.type).then((newList) {
      setState(() {
        list = newList;
      });
    });
  }

  void _addToList(BuildContext context, {String domain}) {
    // TODO add user interaction for domain
    domain = domain == null ? 'thomas.test' : domain;
    ApiProvider().addToList(widget.type, domain).then((_) {
      setState(() {
        list.add(domain);
      });
      showSnackBar(context, 'Added $domain');
      setState(() {});
    }).catchError((e) {
      showSnackBar(context, e.toString());
    });
  }

  void _removeFromList(BuildContext context, String domain) {
    ApiProvider().removeFromList(widget.type, domain).then((_) {
      setState(() {
        list.remove(domain);
      });
      showSnackBar(context, 'Removed $domain',
          action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _addToList(context, domain: domain)));
    }).catchError((e) {
      showSnackBar(context, e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    list.sort();
    return DefaultScaffold(
      title: widget.title,
      fab: FloatingActionButton(
        onPressed: () => _addToList(context),
        child: Icon(Icons.add),
      ),
      body: ListView(
          children: ListTile.divideTiles(
              context: context,
              tiles: list.map((domain) => Dismissible(
                    key: Key(domain),
                    onDismissed: (direction) =>
                        _removeFromList(context, domain),
                    child: ListTile(
                      title: Text(domain),
                    ),
                    background: DismissibleBackground(),
                    secondaryBackground: DismissibleBackground(
                      alignment: Alignment.centerRight,
                    ),
                  ))).toList()),
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
