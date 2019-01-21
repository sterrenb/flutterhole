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
  bool _status;
  bool _statusLoading;

  // only expose a getter to prevent bad usage
  bool get status => _status;

  bool get statusLoading => _statusLoading;

  void setLoading() {
    setState(() {
      _status = _status;
      _statusLoading = true;
    });
  }

  void _setStatus(bool newStatus, {bool doneLoading = true}) {
    setState(() {
      _status = newStatus;
      _statusLoading = !doneLoading;
    });
  }

  Future updateStatus() async {
    setLoading();
    _setStatus(await Api.fetchStatus());
  }

  toggleStatus() async {
    setLoading();
    _setStatus(await Api.setStatus(!_status));
    // Api.fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedState(
      data: this,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    setLoading();
    updateStatus();
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
