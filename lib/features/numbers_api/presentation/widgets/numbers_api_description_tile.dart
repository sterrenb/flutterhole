import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/widgets/layout/open_url_tile.dart';

const String _numbersApiHome = 'http://numbersapi.com/';

class NumbersApiDescriptionTile extends StatelessWidget {
  const NumbersApiDescriptionTile({
    Key key,
    @required this.integer,
  }) : super(key: key);

  final int integer;

  String get url => '$_numbersApiHome#$integer';

  @override
  Widget build(BuildContext context) {
    return OpenUrlTile(
      url: url,
      leading: Icon(KIcons.info),
      title: Row(
        children: <Widget>[
          Text('Powered by the '),
          Text(
            'Numbers API',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
