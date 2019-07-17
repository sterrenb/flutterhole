import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterhole_again/service/pihole_client.dart';

import 'local_storage.dart';

/// Globally accessible class.
class Globals {
  static bool debug = false;
  static Router router;
  static PiholeClient client;
  static LocalStorage localStorage;

  static void refresh(BuildContext context) {
    print('refresh here');
//    BlocProvider.of<StatusBloc>(context).dispatch(FetchStatus());
//    BlocProvider.of<SummaryBloc>(context).dispatch(FetchSummary());
//    BlocProvider.of<WhitelistBloc>(context).dispatch(FetchWhitelist());
  }
}
