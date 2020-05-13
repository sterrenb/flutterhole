import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/single_client_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/many_query_tiles_builder.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/widgets/layout/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/loading_indicators.dart';

class SingleClientPage extends StatelessWidget {
  const SingleClientPage({
    Key key,
    @required this.client,
  }) : super(key: key);

  final PiClient client;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SingleClientBloc>(
      create: (_) =>
          SingleClientBloc()..add(SingleClientEvent.fetchQueries(client)),
      child: PiholeThemeBuilder(
        child: Scaffold(
          appBar: AppBar(
            title: Text('${client.titleOrIp}'),
          ),
          body: Center(
            child: Builder(
              builder: (context) {
                return BlocBuilder<SingleClientBloc, SingleClientState>(
                  builder: (BuildContext context, SingleClientState state) {
                    return state.maybeWhen(
                      success: (client, queries) =>
                          ManyQueryTilesBuilder(queries: queries),
                      failure: (failure) => CenteredFailureIndicator(failure),
                      orElse: () => CenteredLoadingIndicator(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
