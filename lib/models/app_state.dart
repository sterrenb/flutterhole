import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';

class AppState extends StatefulWidget {
  final Widget child;

  AppState({this.child});

  @override
  _AppStateState createState() => _AppStateState();

  static _AppStateState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedState)
            as _InheritedState)
        .data;
  }
}

class _AppStateState extends State<AppState> {
  bool _enabled;
  bool _connected;
  bool _authorized;
  bool _loading;

  // only expose a getter to prevent bad usage
  bool get enabled => _enabled;

  bool get connected => _connected;

  bool get authorized => _authorized;

  bool get loading => _loading;

  @override
  void initState() {
    super.initState();
    setState(() {
      _enabled = false;
      _connected = false;
      _authorized = false;
      _loading = true;
    });

    updateStatus();
    updateAuthorized();
  }

  Future<bool> updateAuthorized() async {
    try {
      bool isAuthorized = await Api.isAuthorized();
      _setAuthorized(isAuthorized);
      return isAuthorized;
    } catch (e) {
      _setAuthorized(false);
    }

    return false;
  }

  void _setAuthorized(bool newAuthorized) {
    setState(() {
      _authorized = newAuthorized;
    });
  }

  void _setConnected(bool newConnected, {bool doneLoading = true}) {
    print('setting connected: $connected');
    setState(() {
      _connected = newConnected;
      _authorized = newConnected;
      _loading = !doneLoading;
    });
  }

  void setLoading() {
    setState(() {
      _loading = true;
    });
  }

  void _setStatus(bool newStatus, {bool doneLoading = true}) {
    print('setting status: $newStatus');
    setState(() {
      _enabled = newStatus;
      _loading = !doneLoading;
      _connected = true;
    });
  }

  void updateStatus() async {
    setLoading();
    try {
      _setStatus(await Api.fetchStatus());
    } catch (e) {
      _setConnected(false);
    }
  }

  void toggleStatus() async {
    setLoading();
    try {
      _setStatus(await Api.setStatus(!_enabled));
    } catch (e) {
      _setConnected(false);
      throw Exception('Failed to toggle status - is your API token correct?');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedState(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedState extends InheritedWidget {
  final _AppStateState data;

  _InheritedState({Key key, this.data, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedState old) {
    return true;
  }
}
