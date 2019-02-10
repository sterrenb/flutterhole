import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:sterrenburg.github.flutterhole/models/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/friendly_exception.dart';

class PrivacyScreen extends StatefulWidget {
  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  Future<String> getPrivacyString() async {
    final response = await http.get(
        'https://raw.githubusercontent.com/sterrenburg/flutterhole/master/PRIVACY.md');
    if (response.statusCode == 200) {
      return response.body;
    }

    throw Exception('Failed to load privacy policy');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Privacy',
      body: FutureBuilder<String>(
          future: getPrivacyString(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Markdown(data: snapshot.data);
            }
            if (snapshot.hasError) {
              return FriendlyException(
                message: snapshot.error.toString(),
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
