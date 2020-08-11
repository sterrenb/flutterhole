import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'whitelist.freezed.dart';
part 'whitelist.g.dart';

@freezed
abstract class Whitelist extends MapModel implements _$Whitelist {
  @JsonSerializable(explicitToJson: true)
  const factory Whitelist({
    List<WhitelistItem> data,
  }) = _Whitelist;

  factory Whitelist.fromJson(Map<String, dynamic> json) =>
      _$WhitelistFromJson(json);

  factory Whitelist.fromList(List<dynamic> list) => Whitelist(
        data: List<WhitelistItem>.from((list.first)),
      );
}
