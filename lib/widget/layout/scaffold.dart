import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/default_drawer.dart';
import 'package:flutterhole/widget/layout/default_end_drawer.dart';
import 'package:flutterhole/widget/layout/search_options.dart';
import 'package:flutterhole/widget/status/status_app_bar.dart';
import 'package:provider/provider.dart';

void showSnackBar(BuildContext context, Widget content) {
  Scaffold.of(context).showSnackBar(SnackBar(content: content));
}

class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget floatingActionButton;
  final List<Widget> actions;

  const DefaultScaffold({
    Key key,
    @required this.title,
    @required this.body,
    this.floatingActionButton,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: StatusAppBar(title: title, actions: actions),
      drawer: DefaultDrawer(),
      endDrawer: DefaultEndDrawer(),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}

class SearchScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final Widget floatingActionButton;
  final bool withDrawer;
  final String initialValue;

  const SearchScaffold({
    Key key,
    @required this.title,
    @required this.body,
    this.floatingActionButton,
    this.withDrawer = true,
    this.initialValue = '',
  }) : super(key: key);

  @override
  _SearchScaffoldState createState() => _SearchScaffoldState();
}

class _SearchScaffoldState extends State<SearchScaffold> {
  bool searching;
  SearchOptions options;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    searching = widget.initialValue.isNotEmpty;
    _controller.text = widget.initialValue;
    options = SearchOptions(widget.initialValue);

    _controller.addListener(() {
      setState(() {
        options = SearchOptions(_controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: searching
          ? AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          autofocus: widget.initialValue.isEmpty,
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
          onChanged: (String search) {
            setState(() {
              options = SearchOptions(search);
            });
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          tooltip: 'Stop searching',
          onPressed: () {
            setState(() {
              searching = false;
              options = SearchOptions();
            });
          },
        ),
      )
          : StatusAppBar(title: widget.title, actions: [
        IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                searching = true;
              });
            }),
      ]),
      drawer: widget.withDrawer ? DefaultDrawer() : null,
      endDrawer: searching ? null : DefaultEndDrawer(),
      floatingActionButton: widget.floatingActionButton,
      body: Provider<SearchOptions>.value(
        value: options, // str
        child: widget.body,
      ),
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
  final String title;
  final Widget body;
  final Widget drawer;
  final List<Widget> actions;
  final Widget floatingActionButton;

  const SimpleScaffold({
    Key key,
    @required this.title,
    @required this.body,
    this.drawer,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          title,
          overflow: TextOverflow.fade,
        ),
        actions: this.actions,
      ),
      drawer: this.drawer,
      floatingActionButton: this.floatingActionButton,
      body: SafeArea(child: body),
    );
  }
}
