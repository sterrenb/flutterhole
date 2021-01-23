import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/pihole_repository.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat();
var _percentFormat = NumberFormat.percentPattern();

Future<OkCancelResult> showErrorAlertDialog(
        BuildContext context, Object e, StackTrace s) =>
    showOkAlertDialog(
      context: context,
      message: '$e \n\nStack trace:\n$s',
    );

class TextTileContent extends StatelessWidget {
  final String top;
  final String bottom;

  const TextTileContent({
    Key key,
    @required this.top,
    @required this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Text(
            top,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        Center(
          child: Text(
            bottom,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class TotalQueriesTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.green,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) => showOkAlertDialog(
              context: context,
              message: summary.toString(),
            ),
            error: (e, s) => showErrorAlertDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Total Queries',
          bottom: summary.when(
            data: (summary) => _numberFormat.format(summary.dnsQueriesToday),
            loading: () => '',
            error: (e, s) => '---',
          ),
        ),
      ),
    );
  }
}

class QueriesBlockedTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.lightBlue,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) => showOkAlertDialog(
              context: context,
              message: summary.toString(),
            ),
            error: (e, s) => showErrorAlertDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Queries Blocked',
          bottom: summary.when(
            data: (summary) => _numberFormat.format(summary.adsBlockedToday),
            loading: () => '',
            error: (e, s) => '---',
          ),
        ),
      ),
    );
  }
}

class PercentBlockedTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.orange,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) => showOkAlertDialog(
              context: context,
              message: summary.toString(),
            ),
            error: (e, s) => showErrorAlertDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Percent Blocked',
          bottom: summary.when(
            data: (summary) =>
                '${summary.adsPercentageToday.toStringAsFixed(2)}%',
            loading: () => '',
            error: (e, s) => '---',
          ),
        ),
      ),
    );
  }
}

class DomainsOnBlocklistTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.redAccent,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) => showOkAlertDialog(
              context: context,
              message: summary.toString(),
            ),
            error: (e, s) => showErrorAlertDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Domains on Blocklist',
          bottom: summary.when(
            data: (summary) =>
                _numberFormat.format(summary.domainsBeingBlocked),
            loading: () => '',
            error: (e, s) => '---',
          ),
        ),
      ),
    );
  }
}
