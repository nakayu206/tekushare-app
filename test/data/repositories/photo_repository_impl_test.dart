import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/data/repositories/photo_repository_impl.dart';
import 'package:tekushare/data/repositories/spot_repository_impl.dart';
import 'package:tekushare/domain/entities/spot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late PhotoRepositoryImpl repo;
  late SpotRepositoryImpl spotRepo;

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('isar_photo_');
    isar = await Isar.open([SpotModelSchema], directory: dir.path);
    repo = PhotoRepositoryImpl(isar);
    spotRepo = SpotRepositoryImpl(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Spot makeSpot() => Spot(
        id: 'spot-1',
        title: 'テストスポット',
        latitude: 35.6895,
        longitude: 139.6917,
        status: SpotStatus.wantToGo,
        createdAt: DateTime(2024, 1, 1),
      );

  group('PhotoRepositoryImpl', () {
    test('attachPhoto でスポットに画像パスを紐づけできる', () async {
      await spotRepo.saveSpot(makeSpot());
      await repo.attachPhoto('spot-1', '/photos/test.jpg');

      final result = await spotRepo.getSpots().first;
      expect(result.first.photoPath, '/photos/test.jpg');
    });

    test('attachPhoto で存在しない spotId を指定しても例外にならない', () async {
      await expectLater(
        repo.attachPhoto('no-such-id', '/photos/test.jpg'),
        completes,
      );
    });

    test('attachPhoto で画像パスを上書きできる', () async {
      await spotRepo.saveSpot(makeSpot());
      await repo.attachPhoto('spot-1', '/photos/first.jpg');
      await repo.attachPhoto('spot-1', '/photos/updated.jpg');

      final result = await spotRepo.getSpots().first;
      expect(result.first.photoPath, '/photos/updated.jpg');
    });
  });
}
