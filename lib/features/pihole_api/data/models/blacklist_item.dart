import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'blacklist_item.freezed.dart';

part 'blacklist_item.g.dart';

@freezed
abstract class BlacklistItem extends MapModel with _$BlacklistItem {
  const factory BlacklistItem({
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
  }) = _BlacklistItem;

  factory BlacklistItem.fromJson(Map<String, dynamic> json) =>
      _$BlacklistItemFromJson(json);
}
