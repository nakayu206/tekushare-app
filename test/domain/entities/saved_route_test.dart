import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/entities/saved_route.dart';

void main() {
  group('SavedRoute', () {
    test('holds all fields correctly', () {
      final createdAt = DateTime(2026, 2, 7);
      final route = SavedRoute(
        id: 1,
        name: '公園コース',
        date: '2/7',
        distance: '1.2km',
        time: '約15分',
        createdAt: createdAt,
      );

      expect(route.id, 1);
      expect(route.name, '公園コース');
      expect(route.date, '2/7');
      expect(route.distance, '1.2km');
      expect(route.time, '約15分');
      expect(route.createdAt, createdAt);
    });
  });
}
