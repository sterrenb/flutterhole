import 'dart:async';
import 'dart:convert';

import 'package:sterrenburg.github.flutterhole/api/api_provider.dart';

/// The type of possible lists that the API understands.
enum ListType {
  black,
  white,
  wild,
  regex,
}

/// The canonical names of the lists returned by the API.
enum BlacklistType {
  exact,
  wildcard,
}

/// Converts the API JSON response from list endpoints into lists.
List<List<String>> listFromJson(String str) {
  final jsonData = json.decode(str);
  return List<List<String>>.from(
      jsonData.map((x) => List<String>.from(x.map((x) => x))));
}

/// The abstract model describing the list endpoints of the API.
abstract class ListModel {
  List<List<String>> lists = [];

  final ListType type;

  ApiProvider _provider;

  ListModel(this.type) {
    _provider = ApiProvider();
  }

  /// Requests an update from the server.
  Future<void> update() async {
    lists = await _provider.fetchList(type);
  }

  /// Adds the [domain] to the list of type [subType].
  Future<void> add(String domain, {ListType subType}) async {
    try {
      await _provider.addToList(subType == null ? type : subType, domain);
    } catch (e) {
      rethrow;
    }
  }

  /// Removes the [domain] from the list of type [subType].
  Future<void> remove(String domain, {ListType subType}) async {
    try {
      await _provider.removeFromList(subType == null ? type : subType, domain);
    } catch (e) {
      rethrow;
    }
  }

  /// Returns true if the model contains [domain], false otherwise.
  bool contains(String domain);
}

/// The model describing the whitelist endpoint.
class WhitelistModel extends ListModel {
  WhitelistModel() : super(ListType.white);

  Future<List<String>> fetch() async {
    await super.update();
    return lists.first;
  }

  @override
  Future<void> add(String domain, {ListType subType}) async {
    try {
      await super.add(domain, subType: subType);
      lists.first.add(domain);
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool contains(String domain) => lists.first.contains(domain);
}

/// The model describing the blacklist endpoint, including wildcard and regex.
class BlacklistModel extends ListModel {
  BlacklistModel({ListType type = ListType.black}) : super(type);

  @override
  bool contains(String domain) {
    lists.forEach((list) {
      if (list.contains(domain)) return true;
    });

    return false;
  }

  Future<List<List<String>>> fetch() async {
    await super.update();
    return lists;
  }
}
