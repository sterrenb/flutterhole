import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum BlacklistType { Exact, Wildcard, Regex }

const String wildcardPrefix = ('(^\|\\\.)');
const String wildcardSuffix = ('\$');

const String _exact = 'exact';
const String _wildcard = 'wildcard';
const String _regex = 'regex';

BlacklistType blacklistTypeFromString(String str) {
  str = str.toLowerCase();
  if (str.contains(_exact)) return BlacklistType.Exact;
  if (str.contains(_wildcard)) return BlacklistType.Wildcard;
  if (str.contains(_regex)) return BlacklistType.Regex;

  throw FormatException('unknown blacklist string $str');
}

class BlacklistItem extends Equatable {
  final String entry;
  final BlacklistType type;

  String get listKey {
    switch (this.type) {
      case BlacklistType.Exact:
        return _exact;
      case BlacklistType.Wildcard:
        return _wildcard;
      case BlacklistType.Regex:
        return _regex;
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

  Blacklist({@required this.exact, @required this.wildcard})
      : super([exact, wildcard]);

  factory Blacklist.fromJson(List<dynamic> json) {
    List<String> exactStrings = List<String>.from(json[0]);
    List<String> wildcardStrings = List<String>.from(json[1]);
    return Blacklist(
        exact: exactStrings.map((String entry) {
          return BlacklistItem(entry: entry, type: BlacklistType.Exact);
        }).toList(),
        wildcard: wildcardStrings.map((String entry) {
          final type = entry.startsWith(wildcardPrefix)
              ? BlacklistType.Wildcard
              : BlacklistType.Regex;
          return BlacklistItem(entry: entry, type: type);
        }).toList());
  }

  String toJson() => ([exact, wildcard]).toString();
}
