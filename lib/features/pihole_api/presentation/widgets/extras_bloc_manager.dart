import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/features/pihole_api/blocs/extras_bloc.dart';

/// Pauses [ExtrasBloc] when the app is not active
class ExtrasBlocManager extends StatefulWidget {
  final Widget child;

  const ExtrasBlocManager({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _ExtrasBlocManagerState createState() => _ExtrasBlocManagerState();
}

class _ExtrasBlocManagerState extends State<ExtrasBlocManager>
    with WidgetsBindingObserver {
  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });

    switch (_notification) {
      case AppLifecycleState.resumed:
        BlocProvider.of<ExtrasBloc>(context).add(ExtrasEvent.start());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        BlocProvider.of<ExtrasBloc>(context).add(ExtrasEvent.stop());
        break;
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
