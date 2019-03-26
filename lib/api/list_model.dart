import 'dart:async';
import 'dart:convert';

import 'package:sterrenburg.github.flutterhole/api/api_provider.dart';

enum ListType {
  black,
  white,
}

List<List<String>> listFromJson(String str) {
  final jsonData = json.decode(str);
  return List<List<String>>.from(
      jsonData.map((x) => List<String>.from(x.map((x) => x))));
}

abstract class ListModel {
  List<List<String>> lists = [];

  final ListType type;

  ApiProvider _provider;

  ListModel(this.type) {
    _provider = ApiProvider();
  }

  Future<void> update() async {
    lists = await _provider.fetchList(type);
  }

  Future<void> add(String domain) async {
    try {
      await _provider.addToList(type, domain);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> remove(String domain) async {
    try {
      await _provider.removeFromList(type, domain);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetch();
}

class WhiteListModel extends ListModel {
  WhiteListModel() : super(ListType.white);

  @override
  Future<List<String>> fetch() async {
    await super.update();
    return lists.first;
  }

  @override
  Future<void> add(String domain) async {
    try {
      await super.add(domain);
      lists.first.add(domain);
    } catch (e) {
      rethrow;
    }
  }
}