import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/summary/bloc.dart';

class Summary extends StatefulWidget {
  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  String _numWithCommas(num i) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final Function matchFunc = (Match match) => '${match[1]},';
    return i.toString().replaceAllMapped(reg, matchFunc);
  }

  @override
  Widget build(BuildContext context) {
    final SummaryBloc summaryBloc = BlocProvider.of<SummaryBloc>(context);
    return BlocListener(
      bloc: summaryBloc,
      listener: (context, state) {
        if (state is SummaryStateEmpty) {
          summaryBloc.dispatch(FetchSummary());
        }
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: BlocBuilder(
                bloc: summaryBloc,
                builder: (BuildContext context, SummaryState state) {
                  if (state is SummaryStateSuccess) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SummaryTile(
                          backgroundColor: Colors.green,
                          title: 'Total Queries',
                          subtitle:
                              _numWithCommas(state.summary.dnsQueriesToday),
                        ),
                        SummaryTile(
                          backgroundColor: Colors.blue,
                          title: 'Queries Blocked',
                          subtitle:
                              _numWithCommas(state.summary.adsBlockedToday),
                        ),
                        SummaryTile(
                          backgroundColor: Colors.orange,
                          title: 'Percent Blocked',
                          subtitle:
                              '${state.summary.adsPercentageToday.toStringAsFixed(1)}%',
                        ),
                        SummaryTile(
                          backgroundColor: Colors.red,
                          title: 'Domains on Blocklist',
                          subtitle:
                              _numWithCommas(state.summary.domainsBeingBlocked),
                        ),
                      ],
                    );
                  }

                  if (state is SummaryStateError) {
                    return ErrorMessage(errorMessage: state.errorMessage);
                  }

                  return Center(child: CircularProgressIndicator());
                }),
          ),
        ],
      ),
    );
  }
}

class SummaryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const SummaryTile({
    Key key,
    @required this.title,
    this.subtitle = 'nmulll',
    @required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      color: backgroundColor,
      child: Center(
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));

    return Expanded(
        child: Container(color: backgroundColor, child: Text(title)));
  }
}

class ErrorMessage extends StatelessWidget {
  final String errorMessage;

  const ErrorMessage({Key key, @required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(errorMessage));
  }
}
