import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_response.freezed.dart';
part 'list_response.g.dart';

@freezed
abstract class ListResponse extends MapModel implements _$ListResponse {
  @JsonSerializable(explicitToJson: true)
  const factory ListResponse({
    bool success,
    String message,
  }) = _ListResponse;

  factory ListResponse.fromJson(Map<String, dynamic> json) =>
      _$ListResponseFromJson(json);
}
