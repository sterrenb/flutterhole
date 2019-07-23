import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/versions.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VersionsState extends Equatable {
  VersionsState([List props = const []]) : super(props);
}

class VersionsStateEmpty extends VersionsState {}

class VersionsStateLoading extends VersionsState {}

class VersionsStateSuccess extends VersionsState {
  final Versions versions;

  VersionsStateSuccess(this.versions) : super([versions]);
}

class VersionsStateError extends VersionsState {
  final PiholeException e;

  VersionsStateError({this.e}) : super([e]);
}
