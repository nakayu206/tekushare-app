import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';
import 'package:tekushare/domain/entities/walk_route.dart';

void main() {
  final createdAt = DateTime(2024, 1, 1);
  final points = [
    const LatLng(35.6895, 139.6917),
    const LatLng(35.6900, 139.6920),
  ];

  WalkRoute makeRoute() {
    return WalkRoute(
      id: 'route-1',
      walkSessionId: 'session-1',
      points: points,
      createdAt: createdAt,
    );
  }

  group('WalkRouteModel', () {
    test('fromEntity でエンティティからモデルに変換できる', () {
      final model = WalkRouteModel.fromEntity(makeRoute());

      expect(model.uid, 'route-1');
      expect(model.walkSessionId, 'session-1');
      expect(model.createdAt, createdAt);
      expect(model.pointsJson, isNotEmpty);
    });

    test('toEntity でモデルからエンティティに変換できる', () {
      final model = WalkRouteModel.fromEntity(makeRoute());
      final route = model.toEntity();

      expect(route.id, 'route-1');
      expect(route.walkSessionId, 'session-1');
      expect(route.createdAt, createdAt);
    });

    test('ポイントリストが正しく変換される', () {
      final model = WalkRouteModel.fromEntity(makeRoute());
      final route = model.toEntity();

      expect(route.points.length, 2);
      expect(route.points[0].latitude, 35.6895);
      expect(route.points[0].longitude, 139.6917);
      expect(route.points[1].latitude, 35.6900);
      expect(route.points[1].longitude, 139.6920);
    });

    test('空のポイントリストが変換できる', () {
      final emptyRoute = WalkRoute(
        id: 'route-1',
        walkSessionId: 'session-1',
        points: [],
        createdAt: createdAt,
      );
      final model = WalkRouteModel.fromEntity(emptyRoute);
      final route = model.toEntity();

      expect(route.points, isEmpty);
    });
  });
}
