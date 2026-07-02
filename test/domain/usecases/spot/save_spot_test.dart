import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';

import 'save_spot_test.mocks.dart';

@GenerateMocks([SpotRepository])
void main() {
  late MockSpotRepository mockRepo;
  late SaveSpot usecase;

  setUp(() {
    mockRepo = MockSpotRepository();
    usecase = SaveSpot(mockRepo);
    when(mockRepo.saveSpot(any)).thenAnswer((_) => Future<void>.value());
  });

  group('SaveSpot', () {
    test('saveSpot が1回呼ばれる', () async {
      await usecase.call(
        title: 'カフェ',
        latitude: 35.6895,
        longitude: 139.6917,
      );
      verify(mockRepo.saveSpot(any)).called(1);
    });

    test('渡したタイトル・座標でスポットが保存される', () async {
      Spot? captured;
      when(mockRepo.saveSpot(any)).thenAnswer((inv) {
        captured = inv.positionalArguments[0] as Spot;
        return Future<void>.value();
      });

      await usecase.call(
        title: 'カフェ',
        latitude: 35.6895,
        longitude: 139.6917,
        memo: 'おすすめ',
      );

      expect(captured?.title, 'カフェ');
      expect(captured?.latitude, 35.6895);
      expect(captured?.longitude, 139.6917);
      expect(captured?.memo, 'おすすめ');
      expect(captured?.status, SpotStatus.wantToGo);
    });

    test('デフォルトのステータスは wantToGo', () async {
      Spot? captured;
      when(mockRepo.saveSpot(any)).thenAnswer((inv) {
        captured = inv.positionalArguments[0] as Spot;
        return Future<void>.value();
      });

      await usecase.call(title: 'テスト', latitude: 0, longitude: 0);

      expect(captured?.status, SpotStatus.wantToGo);
    });

    test('status を visited で指定できる', () async {
      Spot? captured;
      when(mockRepo.saveSpot(any)).thenAnswer((inv) {
        captured = inv.positionalArguments[0] as Spot;
        return Future<void>.value();
      });

      await usecase.call(
        title: 'テスト',
        latitude: 0,
        longitude: 0,
        status: SpotStatus.visited,
      );

      expect(captured?.status, SpotStatus.visited);
    });

    test('生成したスポットIDを返す', () async {
      Spot? captured;
      when(mockRepo.saveSpot(any)).thenAnswer((inv) {
        captured = inv.positionalArguments[0] as Spot;
        return Future<void>.value();
      });

      final id = await usecase.call(title: 'テスト', latitude: 0, longitude: 0);

      expect(id, isNotEmpty);
      expect(id, captured?.id);
    });
  });
}
