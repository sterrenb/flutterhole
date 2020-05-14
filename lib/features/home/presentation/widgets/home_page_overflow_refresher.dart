import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/pi_connection_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef void OnRefreshCallback(BuildContext context);

class HomePageOverflowRefresher extends StatefulWidget {
  const HomePageOverflowRefresher({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _HomePageOverflowRefresherState createState() =>
      _HomePageOverflowRefresherState();
}

class _HomePageOverflowRefresherState extends State<HomePageOverflowRefresher> {
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() {
    BlocProvider.of<HomeBloc>(context).add(HomeEvent.fetch());

    final connectionBloc = getIt<PiConnectionBloc>();
    if (!(connectionBloc.state is PiConnectionStateSleeping)) {
      connectionBloc.add(PiConnectionEvent.ping());
    }
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
