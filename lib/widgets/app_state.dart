import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/api_provider.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_config_name.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_hostname.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_port.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_ssl.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_token.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_view.dart';

/// A global state manager, used for sharing state within different Widgets with [child] as its root.
class AppState extends StatefulWidget {
  /// The child has access to the app state, usually a high level Widget.
  final Widget child;

  /// Defines the theme, either light or dark.
  final Brightness brightness;

  AppState({@required this.child, @required this.brightness});

  @override
  AppStateState createState() => AppStateState();

  static AppStateState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedState)
            as _InheritedState)
        .data;
  }
}

class AppStateState extends State<AppState> {
  /// Whether the Pi-hole is enabled.
  bool _enabled;

  /// Whether the app is connected.
  bool _connected;

  /// Whether the app is authorized with a valid API token.
  bool _authorized;

  /// Whether the app is loading any API data.
  bool _loading;

  /// Whether the app is sleeping for a specified duration.
  Duration _sleeping;

  ApiProvider provider;

  PiConfig piConfig;

  bool get enabled => _enabled;

  bool get connected => _connected;

  bool get authorized => _authorized;

  bool get loading => _loading;

  Duration get sleeping => _sleeping;

  Preference preferenceHostname = PreferenceHostname();
  Preference preferencePort = PreferencePort();
  Preference preferenceSSL = PreferenceSSL();
  Preference preferenceToken = PreferenceToken();
  Preference preferenceConfigName = PreferenceConfigName();
  Preference preferenceIsDark = PreferenceIsDark();

  /// Returns a list of all preferences
  /// in an order that is maintained on [SettingsScreen].
  List<Preference> allPreferences() =>
      [
        preferenceIsDark,
        preferenceHostname,
        preferencePort,
        preferenceToken,
        preferenceSSL,
        preferenceConfigName,
      ];

  @override
  void initState() {
    super.initState();
    setState(() {
      _enabled = false;
      _connected = false;
      _authorized = false;
      _loading = true;
      _sleeping = Duration();
      provider = ApiProvider();
      piConfig = PiConfig();
    });

    updateStatus();
    updateAuthorized();
  }

  bool isSleeping() {
    return _sleeping.inSeconds == 0;
  }

  Future<bool> updateAuthorized() async {
    try {
      bool isAuthorized = await provider.isAuthorized();
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

  Timer _startTimer() {
    return Timer.periodic(Duration(seconds: 1), _onTimer);
  }

  void _onTimer(Timer timer) {
    setState(() {
      _sleeping = Duration(seconds: _sleeping.inSeconds - 1);
    });
    if (_sleeping.inSeconds <= 0) {
      timer.cancel();
      resetSleeping(newStatus: true);
    }
  }

  void _setSleeping(Duration duration) {
    setState(() {
      _sleeping = duration;
    });
    _startTimer();
  }

  void resetSleeping({bool newStatus}) async {
    setState(() {
      _sleeping = Duration();
    });
    if (newStatus != null) {
      _setStatus(await provider.setStatus(newStatus));
    }
  }

  void _setStatus(bool newStatus, {bool doneLoading = true}) {
    setState(() {
      _enabled = newStatus;
      _loading = !doneLoading;
      _connected = true;
    });
  }

  void updateStatus() async {
    setLoading();
    try {
      updateAuthorized();
      _setStatus(await provider.fetchEnabled());
    } catch (e) {
      _setConnected(false);
    }
  }

  void toggleStatus() async {
    setLoading();
    try {
      _setStatus(await provider.setStatus(!_enabled));
      resetSleeping();
    } catch (e) {
      _setConnected(false);
      throw Exception('Failed to toggle status - is your API token correct?');
    }
  }

  void enableStatus() async {
    setLoading();
    try {
      _setStatus(await provider.setStatus(true));
    } catch (e) {
      _setConnected(false);
      throw Exception('Failed to enable status - is your API token correct?');
    }
  }

  void disableStatus({Duration duration}) async {
    setLoading();
    if (duration != null && duration.inSeconds > 0) _setSleeping(duration);

    try {
      _setStatus(await provider.setStatus(false, duration: duration));
    } catch (e) {
      _setConnected(false);
      resetSleeping();
      throw Exception('Failed to disable status - is your API token correct?');
    }
  }

  List<Widget> allPreferenceViews(BuildContext context) {
    return AppState.of(context).allPreferences().map((Preference preference) {
      switch (preference.defaultValue.runtimeType) {
        case bool:
          return PreferenceViewBool(preference: preference);
        default:
          return PreferenceViewString(preference: preference);
      }
    }).toList();
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
  final AppStateState data;

  _InheritedState({Key key, this.data, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedState old) {
    return true;
  }
}

abstract class WithAppState<T extends StatefulWidget> extends State<T> {
  AppStateState appState(BuildContext context) {
    return AppState.of(context);
  }

  PiConfig globalPiConfig(BuildContext context) {
    return appState(context).piConfig;
  }
}
