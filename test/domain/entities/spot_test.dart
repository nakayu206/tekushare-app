import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/entities/spot.dart';

void main() {
  final createdAt = DateTime(2024, 1, 1);

  Spot makeSpot({SpotStatus status = SpotStatus.wantToGo}) {
    return Spot(
      id: 'spot-1',
      title: 'テストスポット',
      latitude: 35.6895,
      longitude: 139.6917,
      status: status,
      createdAt: createdAt,
    );
  }

  group('Spot', () {
    test('初期値が正しく設定される', () {
      final spot = makeSpot();

      expect(spot.id, 'spot-1');
      expect(spot.title, 'テストスポット');
      expect(spot.latitude, 35.6895);
      expect(spot.longitude, 139.6917);
      expect(spot.status, SpotStatus.wantToGo);
      expect(spot.memo, isNull);
      expect(spot.photoPath, isNull);
      expect(spot.createdAt, createdAt);
    });

    test('markAsVisited でステータスが visited になる', () {
      final spot = makeSpot(status: SpotStatus.wantToGo);
      final updated = spot.markAsVisited();

      expect(updated.status, SpotStatus.visited);
      expect(updated.id, spot.id);
      expect(updated.title, spot.title);
    });

    test('markAsWantToGo でステータスが wantToGo になる', () {
      final spot = makeSpot(status: SpotStatus.visited);
      final updated = spot.markAsWantToGo();

      expect(updated.status, SpotStatus.wantToGo);
    });

    test('copyWith でタイトルを変更できる', () {
      final spot = makeSpot();
      final updated = spot.copyWith(title: '新しいスポット');

      expect(updated.title, '新しいスポット');
      expect(updated.id, spot.id);
      expect(updated.status, spot.status);
    });

    test('copyWith でメモと写真パスを設定できる', () {
      final spot = makeSpot();
      final updated = spot.copyWith(
        memo: 'おすすめのカフェ',
        photoPath: '/photos/cafe.jpg',
      );

      expect(updated.memo, 'おすすめのカフェ');
      expect(updated.photoPath, '/photos/cafe.jpg');
    });

    test('copyWith で memo を null に戻せる', () {
      final spot = makeSpot().copyWith(memo: 'メモあり');
      final updated = spot.copyWith(memo: null);

      expect(updated.memo, isNull);
    });

    test('copyWith で photoPath を null に戻せる', () {
      final spot = makeSpot().copyWith(photoPath: '/photos/cafe.jpg');
      final updated = spot.copyWith(photoPath: null);

      expect(updated.photoPath, isNull);
    });

    test('copyWith で memo を指定しないと元の値を保持する', () {
      final spot = makeSpot().copyWith(memo: 'メモあり');
      final updated = spot.copyWith(title: '新しいタイトル');

      expect(updated.memo, 'メモあり');
    });
  });
}
