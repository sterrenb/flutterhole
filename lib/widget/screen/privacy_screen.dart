import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class PrivacyScreen extends StatelessWidget {
  Future<String> getPrivacyString() async {
    try {
      final Response response = await Dio().get(
          'https://raw.githubusercontent.com/sterrenburg/flutterhole/master/PRIVACY.md');
      return response.data.toString();
    } catch (e) {
      Fimber.e(e.toString());
      rethrow;
    }
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
              return ErrorMessage(
                errorMessage: snapshot.error.toString(),
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
