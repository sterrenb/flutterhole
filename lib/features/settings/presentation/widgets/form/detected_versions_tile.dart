import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/settings/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';

class DetectedVersionsTile extends StatelessWidget {
  const DetectedVersionsTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PiholeSettingsBloc, PiholeSettingsState>(
      buildWhen: (previous, next) {
        if (previous is PiholeSettingsStateValidated) {
          return false;
        }

        return true;
      },
      builder: (BuildContext context, PiholeSettingsState state) {
        return Column(
          children: <Widget>[
            ListTile(
              title: Text('Detected versions'),
              leading: Icon(
                KIcons.version,
                color: Theme.of(context).accentColor,
              ),
            ),
            state.maybeMap<Widget>(
              validated: (state) {
                return state.versions.fold(
                  (failure) => CenteredFailureIndicator(failure),
                  (versions) => Column(
                    children: <Widget>[
                      _ListTile(
                        title: 'Pi-hole Version',
                        currentVersion: versions.currentCoreVersion,
                        latestVersion: versions.latestCoreVersion,
                        branch: versions.coreBranch,
                      ),
                      _ListTile(
                        title: 'Web Interface Version',
                        currentVersion: versions.currentWebVersion,
                        latestVersion: versions.latestWebVersion,
                        branch: versions.webBranch,
                      ),
                      _ListTile(
                        title: 'FTL Version',
                        currentVersion: versions.currentFtlVersion,
                        latestVersion: versions.latestFtlVersion,
                        branch: versions.ftlBranch,
                      ),
                    ],
                  ),
                );
              },
              // Filling in some empty space in an inelegant fashion
              loading: (_) => Column(
                children: List.generate(
                  3,
                  (index) => ListTile(
                    title: Text(''),
                    subtitle: Text(''),
                  ),
                ),
              ),
              orElse: () => Container(),
            ),
          ],
        );
      },
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    Key key,
    @required this.title,
    @required this.currentVersion,
    @required this.latestVersion,
    @required this.branch,
  }) : super(key: key);

  final String title;
  final String currentVersion;
  final String latestVersion;
  final String branch;

  bool get updateIsAvailable => currentVersion != latestVersion;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title),
          Text('$branch'),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('$currentVersion'),
              Visibility(
                visible: updateIsAvailable,
                child: Text(
                  ' (update available: $latestVersion)',
                  style: TextStyle(color: KColors.warning),
                ),
              ),
            ],
          ),
          Text('Branch'),
        ],
      ),
    );
  }
}
