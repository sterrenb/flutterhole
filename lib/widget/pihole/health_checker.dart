import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/service/browser.dart';

class HealthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<VersionsBloc>(context),
        builder: (context, state) {
          List<Widget> items = [];
          Versions versions;
          if (state is BlocStateSuccess<Versions>) {
            versions = state.data;
          }

          if (state is BlocStateError<Versions>) {
            items = [
              ListTile(
                leading: Icon(Icons.error),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(state.e.message.split(' ').first),
                        content: SingleChildScrollView(
                          child: Text(state.e.toString()),
                        ),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Clipboard.setData(
                                    ClipboardData(text: state.e.toString()));
                              },
                              child: Text('Copy to clipboard')),
                        ],
                      );
                    },
                  );
                },
                title: Text(
                  state.e.message,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Container(),
              ),
              ListTile(title: Container(), subtitle: Container()),
              ListTile(
                leading: Icon(Icons.web),
                trailing: Icon(Icons.keyboard_arrow_right),
                title: Text('Pi-hole community support'),
                subtitle: Text('discourse.pi-hole.net'),
                onTap: () => launchURL('https://discourse.pi-hole.net/'),
              ),
            ];
          } else {
            items.addAll([
              _ListTile(
                title: versions?.coreCurrent ?? 'Loading...',
                subtitle: 'Pi-hole Version',
                latest: versions?.coreLatest,
              ),
              _ListTile(
                title: versions?.webCurrent ?? 'Loading...',
                subtitle: 'Web Interface Version',
                latest: versions?.webLatest,
              ),
              _ListTile(
                  title: versions?.ftlCurrent ?? 'Loading...',
                  subtitle: 'FTL Version',
                  latest: versions?.coreLatest ?? 'Loading...'),
            ]);
          }

          return Column(
            children: items,
          );
        });
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    Key key,
    this.title,
    @required this.subtitle,
    this.latest = '',
  })  : _subtitle =
  '$subtitle${(title != 'Loading...' && latest != null && latest != title &&
      latest.length > 0) ? ' (update available: $latest)' : ''}',
        super(key: key);

  final String title;
  final String subtitle;
  final String latest;

  final String _subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.check),
      title: Text(title),
      subtitle: Text(_subtitle),
    );
  }
}
