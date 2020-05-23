import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/pihole_api/presentation/notifiers/queries_search_notifier.dart';
import 'package:flutterhole/widgets/layout/animate_on_build.dart';
import 'package:provider/provider.dart';

class QueriesSearchAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  QueriesSearchAppBar({
    Key key,
    this.title,
    this.actions,
  }) : super(key: key);

  final Widget title;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  _QueriesSearchAppBarState createState() => _QueriesSearchAppBarState();
}

class _QueriesSearchAppBarState extends State<QueriesSearchAppBar> {
  TextEditingController _searchEditingController;

  @override
  void initState() {
    super.initState();
    _searchEditingController = TextEditingController();
    _searchEditingController.addListener(() {
      setState(() {
        Provider.of<QueriesSearchNotifier>(context, listen: false).searchQuery =
            _searchEditingController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueriesSearchNotifier>(
      builder: (
        BuildContext context,
        QueriesSearchNotifier notifier,
        _,
      ) {
        return AppBar(
          leading: notifier.isSearching
              ? WillPopScope(
                  child: IconButton(
                    tooltip: 'Stop searching',
                    icon: Icon(KIcons.back),
                    onPressed: () {
                      notifier.stopSearching();
                    },
                  ),
                  onWillPop: () async {
                    notifier.stopSearching();
                    return false;
                  },
                )
              : null,
          title: notifier.isSearching
              ? AnimateOnBuild(
                  child: TextField(
                    controller: _searchEditingController,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    style: Theme.of(context).textTheme.headline6.apply(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Search queries...',
                      border: InputBorder.none,
                      suffixIcon: _searchEditingController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: Icon(KIcons.close),
                              color: Theme.of(context).colorScheme.onPrimary,
                              onPressed: () {
                                setState(() {
                                  _searchEditingController.text = '';
                                });
                              },
                            ),
                    ),
                  ),
                )
              : widget.title ?? Container(),
          elevation: 0.0,
          actions: notifier.isSearching
              ? <Widget>[]
              : <Widget>[
                  IconButton(
                    tooltip: 'Search queries',
                    icon: Icon(KIcons.search),
                    onPressed: () {
                      notifier.startSearching();
                    },
                  ),
                  ...widget.actions ?? [],
                ],
        );
      },
    );
  }
}
