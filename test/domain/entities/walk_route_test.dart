import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';
import 'package:tekushare/domain/entities/walk_route.dart';

void main() {
  final createdAt = DateTime(2024, 1, 1);
  const points = [
    LatLng(35.6895, 139.6917),
    LatLng(35.6900, 139.6920),
  ];

  WalkRoute makeRoute() {
    return WalkRoute(
      id: 'route-1',
      walkSessionId: 'session-1',
      points: points,
      createdAt: createdAt,
    );
  }

  group('WalkRoute', () {
    test('初期値が正しく設定される', () {
      final route = makeRoute();

      expect(route.id, 'route-1');
      expect(route.walkSessionId, 'session-1');
      expect(route.points, points);
      expect(route.createdAt, createdAt);
    });

    test('copyWith でポイントリストを更新できる', () {
      final route = makeRoute();
      const newPoints = [
        LatLng(35.6895, 139.6917),
        LatLng(35.6900, 139.6920),
        LatLng(35.6910, 139.6930),
      ];
      final updated = route.copyWith(points: newPoints);

      expect(updated.points, newPoints);
      expect(updated.points.length, 3);
      expect(updated.id, route.id);
    });

    test('copyWith で変更しないフィールドは元の値を保持する', () {
      final route = makeRoute();
      final updated = route.copyWith(walkSessionId: 'session-2');

      expect(updated.walkSessionId, 'session-2');
      expect(updated.id, route.id);
      expect(updated.points, route.points);
      expect(updated.createdAt, route.createdAt);
    });
  });
}
