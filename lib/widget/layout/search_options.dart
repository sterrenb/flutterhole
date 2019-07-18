import 'package:equatable/equatable.dart';

class SearchOptions extends Equatable {
  final String str;

  SearchOptions([this.str = '']) : super([str]);
}
