import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VersionsEvent extends Equatable {
  VersionsEvent([List props = const []]) : super(props);
}

class FetchVersions extends VersionsEvent {
  final Pihole pihole;

  FetchVersions([this.pihole]) : super([pihole]);
}
