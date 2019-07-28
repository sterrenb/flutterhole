import 'package:equatable/equatable.dart';

/// Base class for API model classes.
abstract class Serializable extends Equatable {
  dynamic toJson();

  Serializable([List props = const []]) : super([props]);
}
