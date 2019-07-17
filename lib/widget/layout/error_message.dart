import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String errorMessage;

  const ErrorMessage({Key key, @required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SafeArea(
          minimum: EdgeInsets.all(8.0),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
        ));
  }
}
