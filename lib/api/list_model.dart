import 'dart:convert';

import 'package:flutter/widgets.dart';

enum ListType {
  black,
  white,
}

List<List<String>> listFromJson(String str) {
  final jsonData = json.decode(str);
  return List<List<String>>.from(
      jsonData.map((x) => List<String>.from(x.map((x) => x))));
}

class ListModel {
  final ListType type;

  ListModel(this.type);
}

class WhiteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
