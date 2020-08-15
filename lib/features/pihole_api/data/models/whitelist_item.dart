import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'whitelist_item.freezed.dart';
part 'whitelist_item.g.dart';

const String wildcardPrefix = '(\\.|^)';
const String wildcardSuffix = '\$';

@freezed
abstract class WhitelistItem extends MapModel with _$WhitelistItem {
  factory WhitelistItem({
    int id,
    int type,
    String domain,
    int enabled,
    @JsonKey(
      name: 'date_added',
      fromJson: dateTimeFromPiholeInt,
      toJson: piholeIntFromDateTime,
    )
        DateTime dateAdded,
    @JsonKey(
      name: 'date_modified',
      fromJson: dateTimeFromPiholeInt,
      toJson: piholeIntFromDateTime,
    )
        DateTime dateModified,
    String comment,
    List<int> groups,
  }) = _WhitelistItem;

  factory WhitelistItem.fromJson(Map<String, dynamic> json) =>
      _$WhitelistItemFromJson(json);

  @late
  bool get isEnabled => enabled == 1;

  @late
  bool get isWildcard => domain.startsWith(wildcardPrefix);
}
