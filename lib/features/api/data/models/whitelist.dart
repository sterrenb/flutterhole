import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'whitelist.freezed.dart';

part 'whitelist.g.dart';

@freezed
abstract class Whitelist extends ListModel implements _$Whitelist {
  const Whitelist._();

  const factory Whitelist({List<String> allowed}) = _Whitelist;

  factory Whitelist.fromJson(Map<String, dynamic> json) =>
      _$WhitelistFromJson(json);

  factory Whitelist.fromList(List<dynamic> list) => Whitelist(
        allowed: List<String>.from((list.first)),
      );

  @override
  List<dynamic> toList() => <dynamic>[allowed];
}
