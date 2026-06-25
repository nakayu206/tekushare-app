import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/data/repositories/route_repository_impl.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';
import 'package:tekushare/domain/entities/walk_route.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late RouteRepositoryImpl repo;

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('isar_route_');
    isar = await Isar.open([WalkRouteModelSchema], directory: dir.path);
    repo = RouteRepositoryImpl(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  WalkRoute makeRoute({
    String id = 'route-1',
    String sessionId = 'session-1',
  }) {
    return WalkRoute(
      id: id,
      walkSessionId: sessionId,
      points: [
        const LatLng(35.6895, 139.6917),
        const LatLng(35.6900, 139.6920),
      ],
      createdAt: DateTime(2024, 1, 1),
    );
  }

  group('RouteRepositoryImpl', () {
    test('saveRoute で保存したルートを getAllRoutes で取得できる', () async {
      await repo.saveRoute(makeRoute());

      final result = await repo.getAllRoutes();
      expect(result.length, 1);
      expect(result.first.id, 'route-1');
      expect(result.first.points.length, 2);
    });

    test('getRouteBySessionId でセッションIDに対応するルートを取得できる', () async {
      await repo.saveRoute(makeRoute(sessionId: 'session-a'));
      await repo.saveRoute(makeRoute(id: 'route-2', sessionId: 'session-b'));

      final result = await repo.getRouteBySessionId('session-a');
      expect(result?.id, 'route-1');
    });

    test('getRouteBySessionId で存在しない sessionId は null を返す', () async {
      final result = await repo.getRouteBySessionId('no-such-session');
      expect(result, isNull);
    });

    test('saveRoute は同じ id で upsert される', () async {
      await repo.saveRoute(makeRoute());
      final updated = WalkRoute(
        id: 'route-1',
        walkSessionId: 'session-1',
        points: [const LatLng(1.0, 2.0)],
        createdAt: DateTime(2024, 1, 1),
      );
      await repo.saveRoute(updated);

      final result = await repo.getAllRoutes();
      expect(result.length, 1);
      expect(result.first.points.length, 1);
    });
  });
}
