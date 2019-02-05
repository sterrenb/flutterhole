import 'package:flutter/material.dart';
import 'package:flutter_hole/screens/settings_screen.dart';

class FriendlyException extends StatelessWidget {
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
