import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forward_destinations.freezed.dart';

part 'forward_destinations.g.dart';

@freezed
abstract class ForwardDestination extends MapModel with _$ForwardDestination {
  const factory ForwardDestination({
    String title,
    String ip,
  }) = _ForwardDestination;

  factory ForwardDestination.fromJson(Map<String, dynamic> json) =>
      _$ForwardDestinationFromJson(json);
}

Map<ForwardDestination, double> _valueToForwardDestinations(dynamic value) {
  assert(value is Map);
  return (value as Map).cast<String, double>().map(
    (String string, double percentage) {
      final List<String> splits = string.split('|');
      String title;
      String ip = splits.last;
      if (splits.length > 1) title = splits.first;

      return MapEntry(ForwardDestination(title: title, ip: ip), percentage);
    },
  );
}

dynamic _forwardDestinationsToValue(
        Map<ForwardDestination, double> forwardDestinations) =>
    forwardDestinations.map((forwardDestination, count) => MapEntry(
        '${forwardDestination.title ?? ''}${(forwardDestination.title?.isEmpty ?? true) ? '' : '|'}${forwardDestination.ip}',
        count));

/// {{ base_url  }}?getQuerySources&auth={{ auth  }}
@freezed
abstract class ForwardDestinationsResult extends MapModel
    with _$ForwardDestinationsResult {
  const factory ForwardDestinationsResult(
          {@JsonKey(
            name: 'forward_destinations',
            fromJson: _valueToForwardDestinations,
            toJson: _forwardDestinationsToValue,
          )
              Map<ForwardDestination, double> forwardDestinations}) =
      _ForwardDestinationsResult;

  factory ForwardDestinationsResult.fromJson(Map<String, dynamic> json) =>
      _$ForwardDestinationsResultFromJson(json);
}
