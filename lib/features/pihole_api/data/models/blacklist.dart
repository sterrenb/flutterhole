import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist_item.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'blacklist.freezed.dart';
part 'blacklist.g.dart';

/// {{ base_url  }}?list=black&auth={{ auth  }}
@freezed
abstract class Blacklist extends MapModel implements _$Blacklist {
  @JsonSerializable(explicitToJson: true)
  const factory Blacklist({
    List<BlacklistItem> data,
  }) = _Blacklist;

  factory Blacklist.fromJson(Map<String, dynamic> json) =>
      _$BlacklistFromJson(json);

  factory Blacklist.fromList(List<dynamic> list) => Blacklist(
        data: List<BlacklistItem>.from((list.first)),
      );
}
