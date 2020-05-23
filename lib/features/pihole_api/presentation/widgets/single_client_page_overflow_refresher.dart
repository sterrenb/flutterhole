import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/single_client_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef void OnRefreshCallback(BuildContext context);

class SingleClientPageOverflowRefresher extends StatefulWidget {
  const SingleClientPageOverflowRefresher({
    Key key,
    @required this.client,
    @required this.child,
  }) : super(key: key);

  final PiClient client;
  final Widget child;

  @override
  _SingleClientPageOverflowRefresherState createState() =>
      _SingleClientPageOverflowRefresherState();
}

class _SingleClientPageOverflowRefresherState
    extends State<SingleClientPageOverflowRefresher> {
  final RefreshController _refreshController = RefreshController();

  void _onRefresh() {
    BlocProvider.of<SingleClientBloc>(context)
        .add(SingleClientEvent.fetchQueries(widget.client));
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
      child: BlocListener<SingleClientBloc, SingleClientState>(
        listener: (BuildContext context, SingleClientState state) {
          if (state is SingleClientStateSuccess) {
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
