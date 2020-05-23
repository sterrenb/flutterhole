import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/query_log_bloc.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef void OnRefreshCallback(BuildContext context);

class QueryLogPageOverflowRefresher extends StatefulWidget {
  const QueryLogPageOverflowRefresher({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _QueryLogPageOverflowRefresherState createState() =>
      _QueryLogPageOverflowRefresherState();
}

class _QueryLogPageOverflowRefresherState
    extends State<QueryLogPageOverflowRefresher> {
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() {
    BlocProvider.of<QueryLogBloc>(context).add(
        QueryLogEvent.fetchSome(getIt<PreferenceService>().queryLogMaxResults));
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
      child: BlocListener<QueryLogBloc, QueryLogState>(
        listener: (BuildContext context, QueryLogState state) {
          if (state is QueryLogStateSuccess) {
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
