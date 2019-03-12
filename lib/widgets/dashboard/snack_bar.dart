import 'package:flutter/material.dart';

const Duration _defaultDuration = Duration(seconds: 2);

void showSnackBar(BuildContext context, String text,
    {Duration duration = _defaultDuration}) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: duration,
  ));
}
