import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/status/bloc.dart';

import 'bloc/summary/bloc.dart';
import 'bloc/summary/summary_bloc.dart';
import 'repository/local_storage.dart';

class Summary extends StatefulWidget {
  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  @override
  Widget build(BuildContext context) {
    final SummaryBloc summaryBloc = BlocProvider.of<SummaryBloc>(context);
    final StatusBloc statusBloc = BlocProvider.of<StatusBloc>(context);
    return BlocListener(
      bloc: summaryBloc,
      listener: (context, state) {
        if (state is SummaryStateEmpty) {
          summaryBloc.dispatch(FetchSummary());
        }
      },
      child: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              summaryBloc.dispatch(FetchSummary());
              statusBloc.dispatch(GetStatus());
            },
            child: Text('load'),
          ),
          RaisedButton(
            onPressed: () async {
              final storage = await LocalStorage.getInstance();
              storage.init();
            },
            child: Text('prefs'),
          ),
          Expanded(
            child: BlocBuilder(
                bloc: summaryBloc,
                builder: (BuildContext context, SummaryState state) {
                  if (state is SummaryStateEmpty) {
                    return Center(child: Text('summary empty'));
                  }
                  if (state is SummaryStateLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state is SummaryStateError) {
                    return Center(child: Text(state.errorMessage));
                  }
                  if (state is SummaryStateSuccess) {
                    return ListView(
                      children: <Widget>[
                        ListTile(
                          title: Text(state.summary.adsBlockedToday.toString()),
                          leading: Text('Ads blocked today'),
                        ),
                        ListTile(
                          title: Text(state.summary.status),
                          leading: Text('Status'),
                        ),
                      ],
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
