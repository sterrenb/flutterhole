import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/pihole_api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exceptions.freezed.dart';
part 'exceptions.g.dart';

@freezed
abstract class PiException extends MapModel with _$PiException {
  const factory PiException.notFound(Object error) = NotFoundPiException;

  const factory PiException.timeOut(Object error) = TimeOutPiException;

  const factory PiException.notAuthenticated(Object error) =
      NotAuthenticatedPiException;

  const factory PiException.emptyResponse(Object error) =
      EmptyResponsePiException;

  const factory PiException.malformedResponse(Object error) =
      MalformedResponsePiException;

  factory PiException.fromJson(Map<String, dynamic> json) =>
      _$PiExceptionFromJson(json);
}
