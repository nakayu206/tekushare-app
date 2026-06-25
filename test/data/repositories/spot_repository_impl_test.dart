import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/data/repositories/spot_repository_impl.dart';
import 'package:tekushare/domain/entities/spot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late SpotRepositoryImpl repo;

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('isar_spot_');
    isar = await Isar.open([SpotModelSchema], directory: dir.path);
    repo = SpotRepositoryImpl(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Spot makeSpot({
    String id = 'spot-1',
    SpotStatus status = SpotStatus.wantToGo,
    String title = 'テストスポット',
  }) {
    return Spot(
      id: id,
      title: title,
      latitude: 35.6895,
      longitude: 139.6917,
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  group('SpotRepositoryImpl', () {
    test('saveSpot で保存したスポットを getSpots で取得できる', () async {
      await repo.saveSpot(makeSpot());

      final result = await repo.getSpots().first;
      expect(result.length, 1);
      expect(result.first.id, 'spot-1');
      expect(result.first.title, 'テストスポット');
    });

    test('saveSpot は同じ id で upsert される', () async {
      await repo.saveSpot(makeSpot());
      await repo.saveSpot(makeSpot(title: '更新後'));

      final result = await repo.getSpots().first;
      expect(result.length, 1);
      expect(result.first.title, '更新後');
    });

    test('updateSpotStatus でステータスを変更できる', () async {
      await repo.saveSpot(makeSpot());
      await repo.updateSpotStatus('spot-1', SpotStatus.visited);

      final result = await repo.getSpots().first;
      expect(result.first.status, SpotStatus.visited);
    });

    test('updateSpotStatus で存在しない id を指定しても例外にならない', () async {
      await expectLater(
        repo.updateSpotStatus('no-such-id', SpotStatus.visited),
        completes,
      );
    });

    test('deleteSpot でスポットを削除できる', () async {
      await repo.saveSpot(makeSpot());
      await repo.deleteSpot('spot-1');

      final result = await repo.getSpots().first;
      expect(result, isEmpty);
    });
  });
}
