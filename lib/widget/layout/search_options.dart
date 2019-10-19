import 'package:equatable/equatable.dart';

class SearchOptions extends Equatable {
  SearchOptions([this.str = '']);

  final String str;

  @override
  List<Object> get props => [str];
}
