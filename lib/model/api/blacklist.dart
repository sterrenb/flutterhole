import 'dart:convert';

import 'package:flutterhole/model/serializable.dart';
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

class BlacklistItem extends Serializable {
  final String entry;
  final BlacklistType type;

  /// The string representation of which list to add to in the Pihole API.
  String get addList => type == BlacklistType.Exact ? 'black' : 'regex';

  /// The internal key used for discriminating items.
  String get listKey {
    if (type == BlacklistType.Exact) return _exact;
    if (type == BlacklistType.Wildcard) return _wildcard;
    if (type == BlacklistType.Regex) return _regex;

    throw Exception('unknown BlacklistType $type');
  }

  BlacklistItem({@required this.entry, @required this.type})
      : super([entry, type]);

  factory BlacklistItem.exact({@required entry}) =>
      BlacklistItem(entry: entry, type: BlacklistType.Exact);

  factory BlacklistItem.wildcard({@required entry}) =>
      BlacklistItem(entry: entry, type: BlacklistType.Wildcard);

  factory BlacklistItem.regex({@required entry}) =>
      BlacklistItem(entry: entry, type: BlacklistType.Regex);

  @override
  Map<String, dynamic> toJson() =>
      {
        'entry': entry,
        'type': listKey,
      };
}

/// The API model for http://pi.hole/admin/api.php?list=black.
class Blacklist extends Serializable {
  final List<BlacklistItem> exact;
  final List<BlacklistItem> wildcard;

  Blacklist({this.exact = const [], this.wildcard = const []})
      : super([exact, wildcard]);

  Blacklist.withItem(Blacklist original, BlacklistItem item)
      : this.exact = item.type == BlacklistType.Exact
      ? List.from([
    ...original.exact,
    ...[item]
  ]
    ..sort((a, b) => a.entry.compareTo(b.entry)))
      : original.exact,
        this.wildcard = item.type != BlacklistType.Exact
            ? List.from([
          ...original.wildcard,
          ...[item]
        ]
          ..sort((a, b) => a.entry.compareTo(b.entry)))
            : original.wildcard;

  Blacklist.withoutItem(Blacklist original, BlacklistItem item)
      : this.exact = (item.type == BlacklistType.Exact)
      ? List.from([...original.exact]
    ..remove(item)
    ..sort((a, b) => a.entry.compareTo(b.entry)))
      : original.exact,
        this.wildcard = (item.type != BlacklistType.Exact)
            ? List.from([...original.wildcard]
          ..remove(item)
          ..sort((a, b) => a.entry.compareTo(b.entry)))
            : original.wildcard;

  factory Blacklist.fromString(String str) =>
      Blacklist._fromMap(json.decode(str));

  factory Blacklist._fromMap(dynamic map) {
    final List<BlacklistItem> exact =
    List<BlacklistItem>.from(map['exact'].map((val) {
      return BlacklistItem.exact(entry: val['entry']);
    }));
    final List<BlacklistItem> wildcard =
    List<BlacklistItem>.from(map['wildcard'].map((val) {
      return BlacklistItem(
          entry: val['entry'], type: blacklistTypeFromString(val['type']));
    }));
    return Blacklist(
      exact: exact,
      wildcard: wildcard,
    );
  }

  factory Blacklist.fromJson(List<dynamic> json) {
    List<String> exactStrings = _exactFromJson(json);
    final List<String> wildcardStrings = List<String>.from(json[1]);

    List<BlacklistItem> exact =
    List<BlacklistItem>.from(exactStrings.map((String entry) {
      return BlacklistItem.exact(entry: entry);
    }).toList()
      ..sort((a, b) => a.entry.compareTo(b.entry)));

    List<BlacklistItem> wildcard =
    List<BlacklistItem>.from(wildcardStrings.map((String entry) {
      final BlacklistType type = entry.startsWith(wildcardPrefix)
          ? BlacklistType.Wildcard
          : BlacklistType.Regex;
      return BlacklistItem(entry: entry, type: type);
    }).toList()
          ..sort((a, b) => a.entry.compareTo(b.entry)));

    return Blacklist(exact: exact, wildcard: wildcard);
  }

  static List<String> _exactFromJson(List json) {
    final List<String> exactStrings = List<String>.from(json[0]);
    return exactStrings;
  }

  @override
  Map<String, dynamic> toJson() =>
      {
        'exact': exact,
        'wildcard': wildcard,
      };
}
