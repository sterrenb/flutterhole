import 'package:equatable/equatable.dart';

abstract class Serializable extends Equatable {
  dynamic toJson();

  Serializable([List props = const []]) : super([props]);

//  Serializable.fromJson();
}
