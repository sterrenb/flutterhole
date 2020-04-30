import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/features/api/data/models/model.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';

import 'fixture_reader.dart';

void testModel<T extends Model>(
    String fixtureName, Function1<Map<String, dynamic>, T> fromJson) {
  test(
    '$T should be cyclical',
    () async {
      // arrange
      final Map<String, dynamic> json = jsonFixture('$fixtureName');
      // act
      final T model = fromJson(json);
      final map = model.toJson();
      // assert
      map.forEach((key, value) {
        expect(json, containsPair(key, value));
      });
    },
  );
}

void main() {
  testModel<Summary>('summary.json', (json) => Summary.fromJson(json));
}
