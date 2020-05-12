import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pi_versions.freezed.dart';
part 'pi_versions.g.dart';

/// {{ base_url  }}?versions
@freezed
abstract class PiVersions extends MapModel with _$PiVersions {
  const factory PiVersions({
    @JsonKey(name: 'core_update') bool hasCoreUpdate,
    @JsonKey(name: 'web_update') bool hasWebUpdate,
    @JsonKey(name: 'FTL_update') bool hasFtlUpdate,
    @JsonKey(name: 'core_current') String currentCoreVersion,
    @JsonKey(name: 'web_current') String currentWebVersion,
    @JsonKey(name: 'FTL_current') String currentFtlVersion,
    @JsonKey(name: 'core_latest') String latestCoreVersion,
    @JsonKey(name: 'web_latest') String latestWebVersion,
    @JsonKey(name: 'FTL_latest') String latestFtlVersion,
    @JsonKey(name: 'core_branch') String coreBranch,
    @JsonKey(name: 'web_branch') String webBranch,
    @JsonKey(name: 'FTL_branch') String ftlBranch,
  }) = _PiVersions;

  factory PiVersions.fromJson(Map<String, dynamic> json) =>
      _$PiVersionsFromJson(json);
}
