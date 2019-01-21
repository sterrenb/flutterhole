// Inspired by https://gist.github.com/slightfoot/d549282ac0a5466505db8ffa92279d25
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesBuilder<T> extends StatelessWidget {
  final String pref;
  final AsyncWidgetBuilder<T> builder;

  const SharedPreferencesBuilder({
    Key key,
    @required this.pref,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: _future(),
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          return this.builder(context, snapshot);
        });
  }

  Future<T> _future() async {
    return (await SharedPreferences.getInstance()).get(pref);
  }
}

class DefaultPreference extends StatelessWidget {
  final String pref;

  const DefaultPreference({Key key, @required this.pref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SharedPreferencesBuilder<String>(
      pref: pref,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return snapshot.hasData
            ? Text(snapshot.data.toString())
            : ListTile(
                title: Text(pref),
                subtitle: Text('none'),
              );
      },
    );
  }
}

class Pref {
  final String key;
  StatelessWidget _widget;

  get widget => _widget;

  factory Pref(
    String key,
    Type type,
  ) {
    StatelessWidget widget = DefaultPreference(
      pref: key,
    );

    Function _setter;

    SharedPreferences.getInstance().then((SharedPreferences sharedPreferences) {
      switch (type) {
        case String:
          print("$key: string!");
          _setter = sharedPreferences.setString;
          break;
        case int:
          print("$key: int!");
          _setter = sharedPreferences.setInt;
          break;
      }
    });

    final pref = Pref._internal(key: key, widget: widget, setter: _setter);
    return pref;
  }

  Pref._internal(
      {@required this.key,
      @required StatelessWidget widget,
      @required Function setter}) {
    if (this._widget == null) {
      this._widget = DefaultPreference(
        pref: this.key,
      );
    }
  }
}
