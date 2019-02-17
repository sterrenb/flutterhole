import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/screens/settings_screen.dart';

/// A human friendly exception, use when displaying exceptions to users.
class FriendlyException extends StatelessWidget {
  /// The human friendly message.
  final String message;

  const FriendlyException({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String shownMessage =
        (message == null) ? 'An unknown error occured.' : message;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Text(
              shownMessage,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('View settings'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
