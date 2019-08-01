import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/service/globals.dart';

class Refreshable extends StatefulWidget {
  final RefreshCallBack onRefresh;
  final BaseBloc bloc;
  final Widget child;

  const Refreshable({
    Key key,
    @required this.onRefresh,
    @required this.bloc,
    @required this.child,
  }) : super(key: key);

  @override
  _RefreshableState createState() => _RefreshableState();
}

class _RefreshableState extends State<Refreshable> {
  Completer _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
        bloc: widget.bloc,
        listener: (context, state) {
          if (state is BlocStateSuccess || state is BlocStateError) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            widget.onRefresh(context);
            return _refreshCompleter.future;
          },
          child: widget.child,
        ));
  }
}
