import 'package:flutter/foundation.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'blacklist.freezed.dart';

part 'blacklist.g.dart';

@freezed
abstract class Blacklist extends ListModel implements _$Blacklist {
  const Blacklist._();

  const factory Blacklist({
    List<String> exacts,
    List<String> wildcards,
  }) = _Blacklist;

  factory Blacklist.fromJson(Map<String, dynamic> json) =>
      _$BlacklistFromJson(json);

  factory Blacklist.fromList(List<dynamic> list) => Blacklist(
        exacts: List<String>.from((list.first)),
        wildcards: List<String>.from((list.last)),
      );

  @override
  List<dynamic> toList() {
    return <dynamic>[
      exacts,
      wildcards,
    ];
  }
}
