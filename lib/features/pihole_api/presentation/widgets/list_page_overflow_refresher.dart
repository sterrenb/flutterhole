import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef void OnRefreshCallback(BuildContext context);

class ListPageOverflowRefresher extends StatefulWidget {
  const ListPageOverflowRefresher({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _ListPageOverflowRefresherState createState() =>
      _ListPageOverflowRefresherState();
}

class _ListPageOverflowRefresherState extends State<ListPageOverflowRefresher> {
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() {
    BlocProvider.of<ListBloc>(context).add(ListBlocEvent.fetchLists());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      headerBuilder: () => WaterDropMaterialHeader(
        semanticsLabel: 'Refresh data',
        color: Theme.of(context).colorScheme.onBackground,
      ),
      enableBallisticLoad: true,
      child: BlocListener<ListBloc, ListBlocState>(
        listener: (BuildContext context, ListBlocState state) {
          if (state.loading == false && state.whitelist != null) {
            _refreshController?.refreshCompleted();
          }
        },
        child: SmartRefresher(
          enablePullDown: true,
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: widget.child,
        ),
      ),
    );
  }
}
