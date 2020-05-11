import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef void OnRefreshCallback(BuildContext context);

class HomeBlocOverflowRefresher extends StatefulWidget {
  const HomeBlocOverflowRefresher({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _HomeBlocOverflowRefresherState createState() =>
      _HomeBlocOverflowRefresherState();
}

class _HomeBlocOverflowRefresherState extends State<HomeBlocOverflowRefresher> {
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() {
    BlocProvider.of<HomeBloc>(context).add(HomeEvent.fetch());
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
      child: BlocListener<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          if (state is HomeStateSuccess) {
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
