import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Duration _defaultDuration = Duration(seconds: 2);

void showSnackBar(BuildContext context, String text,
    {Duration duration = _defaultDuration, SnackBarAction action}) {
  try {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: duration,
      action: action,
    ));
  } catch (e) {
    Fluttertoast.showToast(msg: text);
  }
}
