import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/single_domain_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef void OnRefreshCallback(BuildContext context);

class SingleDomainPageOverflowRefresher extends StatefulWidget {
  const SingleDomainPageOverflowRefresher({
    Key key,
    @required this.domain,
    @required this.child,
  }) : super(key: key);

  final String domain;
  final Widget child;

  @override
  _SingleDomainPageOverflowRefresherState createState() =>
      _SingleDomainPageOverflowRefresherState();
}

class _SingleDomainPageOverflowRefresherState
    extends State<SingleDomainPageOverflowRefresher> {
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() {
    BlocProvider.of<SingleDomainBloc>(context)
        .add(SingleDomainEvent.fetchQueries(widget.domain));
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
      child: BlocListener<SingleDomainBloc, SingleDomainState>(
        listener: (BuildContext context, SingleDomainState state) {
          if (state is SingleDomainStateSuccess) {
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
