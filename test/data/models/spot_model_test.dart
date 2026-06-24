import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/domain/entities/spot.dart';

void main() {
  final createdAt = DateTime(2024, 1, 1);

  Spot makeSpot({String? memo, String? photoPath}) {
    return Spot(
      id: 'spot-1',
      title: 'テストスポット',
      latitude: 35.6895,
      longitude: 139.6917,
      status: SpotStatus.wantToGo,
      memo: memo,
      photoPath: photoPath,
      createdAt: createdAt,
    );
  }

  group('SpotModel', () {
    test('fromEntity でエンティティからモデルに変換できる', () {
      final spot = makeSpot(memo: 'メモ', photoPath: '/photos/test.jpg');
      final model = SpotModel.fromEntity(spot);

      expect(model.uid, 'spot-1');
      expect(model.title, 'テストスポット');
      expect(model.latitude, 35.6895);
      expect(model.longitude, 139.6917);
      expect(model.status, SpotStatus.wantToGo);
      expect(model.memo, 'メモ');
      expect(model.photoPath, '/photos/test.jpg');
      expect(model.createdAt, createdAt);
    });

    test('toEntity でモデルからエンティティに変換できる', () {
      final model = SpotModel.fromEntity(makeSpot());
      final spot = model.toEntity();

      expect(spot.id, 'spot-1');
      expect(spot.title, 'テストスポット');
      expect(spot.latitude, 35.6895);
      expect(spot.longitude, 139.6917);
      expect(spot.status, SpotStatus.wantToGo);
      expect(spot.createdAt, createdAt);
    });

    test('memo / photoPath が null のまま変換できる', () {
      final model = SpotModel.fromEntity(makeSpot());
      final spot = model.toEntity();

      expect(spot.memo, isNull);
      expect(spot.photoPath, isNull);
    });

    test('visited ステータスが正しく変換される', () {
      final spot = makeSpot().markAsVisited();
      final model = SpotModel.fromEntity(spot);
      final restored = model.toEntity();

      expect(restored.status, SpotStatus.visited);
    });
  });
}
