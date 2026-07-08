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

    test('walkSessionId defaults to null', () {
      final route = SavedRoute(
        id: 1,
        name: 'テスト',
        date: '2/7',
        distance: '1.0km',
        time: '15分',
        createdAt: DateTime(2026, 2, 7),
      );

      expect(route.walkSessionId, isNull);
    });

    test('holds walkSessionId when provided', () {
      final route = SavedRoute(
        id: 2,
        name: 'GPSコース',
        date: '2/8',
        distance: '2.0km',
        time: '30分',
        createdAt: DateTime(2026, 2, 8),
        walkSessionId: 'session-abc-123',
      );

      expect(route.walkSessionId, 'session-abc-123');
    });
  });
}
