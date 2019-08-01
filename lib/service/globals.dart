import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/api/forward_destinations.dart';
import 'package:flutterhole/bloc/api/queries_over_time.dart';
import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/query_types.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/api/summary.dart';
import 'package:flutterhole/bloc/api/top_items.dart';
import 'package:flutterhole/bloc/api/top_sources.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/bloc/pihole/pihole_bloc.dart';
import 'package:flutterhole/service/memory_tree.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/service/secure_store.dart';

typedef RefreshCallBack = void Function(BuildContext context);

/// Globally accessible class.
class Globals {
  static bool debug = false;
  static MemoryTree tree;
  static Router router;
  static PiholeClient client;

  static SecureStore secureStore;

  static VoidCallback refreshAllBlocs;

  static void _fetchForBlocs(List<BaseBloc> blocs) {
    blocs.forEach((bloc) => bloc.dispatch(Fetch()));
  }

  static RefreshCallBack fetchForHome =
      (BuildContext context) =>
      _fetchForBlocs([
        BlocProvider.of<SummaryBloc>(context),
        BlocProvider.of<StatusBloc>(context),
        BlocProvider.of<ForwardDestinationsBloc>(context),
        BlocProvider.of<TopSourcesBloc>(context),
        BlocProvider.of<TopItemsBloc>(context),
        BlocProvider.of<QueryTypesBloc>(context),
        BlocProvider.of<QueriesOverTimeBloc>(context),
      ]);

  static RefreshCallBack fetchForTopSources =
      (BuildContext context) =>
      _fetchForBlocs([
        BlocProvider.of<SummaryBloc>(context),
        BlocProvider.of<TopSourcesBloc>(context),
      ]);

  static RefreshCallBack fetchForTopItems =
      (BuildContext context) =>
      _fetchForBlocs([
        BlocProvider.of<SummaryBloc>(context),
        BlocProvider.of<TopItemsBloc>(context),
      ]);

  static void fetchForWhitelistView(BuildContext context) =>
      _fetchForBlocs([
        BlocProvider.of<WhitelistBloc>(context),
      ]);

  static void fetchForBlacklistView(BuildContext context) =>
      _fetchForBlocs([
        BlocProvider.of<BlacklistBloc>(context),
      ]);

  static void fetchForQueryView(BuildContext context) =>
      _fetchForBlocs([
        BlocProvider.of<QueryBloc>(context),
        BlocProvider.of<WhitelistBloc>(context),
        BlocProvider.of<BlacklistBloc>(context),
      ]);

  static void fetchForSettingsView(BuildContext context) {
    BlocProvider.of<PiholeBloc>(context).dispatch(FetchPiholes());
  }

  static Future<dynamic> navigateTo(BuildContext context, String path) {
    client.cancel();
    if (path == homePath) fetchForHome(context);
    if (path == whitelistViewPath) fetchForWhitelistView(context);
    if (path == blacklistViewPath) fetchForBlacklistView(context);
    if (path == queryViewPath) fetchForQueryView(context);
    if (path == settingsPath) fetchForSettingsView(context);

    return router.navigateTo(context, path,
        transition: TransitionType.inFromRight);
  }
}
