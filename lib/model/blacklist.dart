import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum BlacklistType { Exact, Wildcard, Regex }

const String wildcardPrefix = ('(^\|\\\.)');
const String wildcardSuffix = ('\$');

const String _exact = 'exact';
const String _wildcard = 'wildcard';
const String regexKey = 'regex';

BlacklistType blacklistTypeFromString(String str) {
  str = str.toLowerCase();
  if (str.contains(_exact)) return BlacklistType.Exact;
  if (str.contains(_wildcard)) return BlacklistType.Wildcard;
  if (str.contains(regexKey)) return BlacklistType.Regex;

  throw FormatException('unknown blacklist string $str');
}

class BlacklistItem extends Equatable {
  final String entry;
  final BlacklistType type;

  String get list => type == BlacklistType.Exact ? 'black' : 'regex';

  String get listKey {
    switch (this.type) {
      case BlacklistType.Exact:
        return _exact;
      case BlacklistType.Wildcard:
        return _wildcard;
      case BlacklistType.Regex:
        return regexKey;
      default:
        throw Exception('unknown BlacklistType ${this.type}');
    }
  }

//  String get list => type == BlacklistType.Exact ? 'black' : 'regex';

  BlacklistItem({@required this.entry, @required this.type})
      : super([entry, type]);

  factory BlacklistItem.exact({@required entry}) =>
      BlacklistItem(entry: entry, type: BlacklistType.Exact);

  factory BlacklistItem.wildcard({@required entry}) =>
      BlacklistItem(entry: entry, type: BlacklistType.Wildcard);

  factory BlacklistItem.regex({@required entry}) =>
      BlacklistItem(entry: entry, type: BlacklistType.Regex);
}

class Blacklist extends Equatable {
  List<BlacklistItem> exact;
  List<BlacklistItem> wildcard;

  Blacklist({this.exact = const [], this.wildcard = const []})
      : super([exact, wildcard]);

  Blacklist.cloneWith(Blacklist blacklist, BlacklistItem item) {
    this.exact = blacklist.exact;
    this.wildcard = blacklist.wildcard;

    if (item.type == BlacklistType.Exact) {
      this.exact.add(item);
    } else {
      this.wildcard.add(item);
    }
  }

  Blacklist.cloneWithout(Blacklist blacklist, BlacklistItem item) {
    this.exact = blacklist.exact;
    this.wildcard = blacklist.wildcard;

    if (item.type == BlacklistType.Exact) {
      this.exact.remove(item);
    } else {
      this.wildcard.remove(item);
    }
  }

  factory Blacklist.fromJson(List<dynamic> json) {
    List<String> exactStrings = List<String>.from(json[0]);
    List<String> wildcardStrings = List<String>.from(json[1]);
    return Blacklist(
        exact: exactStrings.map((String entry) {
          return BlacklistItem(entry: entry, type: BlacklistType.Exact);
        }).toList()
          ..sort((a, b) => a.entry.compareTo(b.entry)),
        wildcard: wildcardStrings.map((String entry) {
          final type = entry.startsWith(wildcardPrefix)
              ? BlacklistType.Wildcard
              : BlacklistType.Regex;
          return BlacklistItem(entry: entry, type: type);
        }).toList()
          ..sort((a, b) => a.entry.compareTo(b.entry)));
  }

  String toJson() => ([exact, wildcard]).toString();
}
