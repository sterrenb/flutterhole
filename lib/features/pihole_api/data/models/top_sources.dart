import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_sources.freezed.dart';

part 'top_sources.g.dart';

Map<PiClient, int> _valueToTopSources(dynamic value) {
  assert(value is Map);
  return (value as Map).cast<String, int>().map(
    (String string, int queryCount) {
      final List<String> splits = string.split('|');
      String title;
      String ip = splits.last;
      if (splits.length > 1) title = splits.first;

      return MapEntry(PiClient(title: title, ip: ip), queryCount);
    },
  );
}

dynamic _topSourcesToValue(Map<PiClient, int> topSources) =>
    topSources.map((client, count) => MapEntry(
        '${client.title ?? ''}${(client.title?.isEmpty ?? true) ? '' : '|'}${client.ip}',
        count));

/// {{ base_url  }}?getQuerySources&auth={{ auth  }}
@freezed
abstract class TopSourcesResult extends MapModel with _$TopSourcesResult {
  const factory TopSourcesResult(
      {@JsonKey(
        name: 'top_sources',
        fromJson: _valueToTopSources,
        toJson: _topSourcesToValue,
      )
          Map<PiClient, int> topSources}) = _TopSourcesResult;

  factory TopSourcesResult.fromJson(Map<String, dynamic> json) =>
      _$TopSourcesResultFromJson(json);
}
