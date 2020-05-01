import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_items.freezed.dart';

part 'top_items.g.dart';

/// {{ base_url  }}?topItems&auth={{ auth  }}
@freezed
abstract class TopItems extends MapModel with _$TopItems {
  const factory TopItems({
    @required @JsonKey(name: 'top_queries') Map<String, int> topQueries,
    @required @JsonKey(name: 'top_ads') Map<String, int> topAds,
  }) = _TopItems;

  factory TopItems.fromJson(Map<String, dynamic> json) =>
      _$TopItemsFromJson(json);
}
