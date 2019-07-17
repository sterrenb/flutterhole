import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/default_drawer.dart';
import 'package:flutterhole/widget/layout/default_end_drawer.dart';
import 'package:flutterhole/widget/status/status_app_bar.dart';

void showSnackBar(BuildContext context, Widget content) {
  Scaffold.of(context).showSnackBar(SnackBar(content: content));
}

class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget floatingActionButton;

  const DefaultScaffold({
    Key key,
    @required this.title,
    @required this.body,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: StatusAppBar(title: title),
      drawer: DefaultDrawer(),
      endDrawer: DefaultEndDrawer(),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}

class TabScaffold extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final List<BottomNavigationBarItem> items;
  final Widget floatingActionButton;

  const TabScaffold({
    Key key,
    @required this.title,
    @required this.children,
    @required this.items,
    this.floatingActionButton,
  })
      : assert(children.length == items.length),
        super(key: key);

  @override
  _TabScaffoldState createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: StatusAppBar(title: widget.title),
      drawer: DefaultDrawer(),
      endDrawer: DefaultEndDrawer(),
      bottomNavigationBar: BottomNavigationBar(
          onTap: _onTap, currentIndex: _currentIndex, items: widget.items),
      floatingActionButton: widget.floatingActionButton,
      body: widget.children[_currentIndex],
    );
  }
}

class SimpleScaffold extends StatelessWidget {
  final String titleString;
  final Widget body;
  final Widget drawer;

  const SimpleScaffold({
    Key key,
    @required this.titleString,
    @required this.body,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          title: Text(
            titleString,
            overflow: TextOverflow.fade,
          )),
      drawer: this.drawer,
      body: body,
    );
  }
}
