import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'many_query_data.freezed.dart';

part 'many_query_data.g.dart';

List<QueryData> _valueToQueryDataList(dynamic value) {
  return (value as List<dynamic>).map((e) => QueryData.fromList(e)).toList();
}

dynamic _queryDataListToValue(List<QueryData> data) {
  return data.map((e) => e.toList()).toList();
}

///   {{ base_url  }}?getAllQueries=123&auth={{ auth  }}
@freezed
abstract class ManyQueryData extends MapModel implements _$ManyQueryData {
  const ManyQueryData._();

  const factory ManyQueryData({
    @JsonKey(
      name: 'data',
      fromJson: _valueToQueryDataList,
      toJson: _queryDataListToValue,
    )
        List<QueryData> data,
  }) = _ManyQueryData;

  factory ManyQueryData.fromJson(Map<String, dynamic> json) =>
      _$ManyQueryDataFromJson(json);
}
