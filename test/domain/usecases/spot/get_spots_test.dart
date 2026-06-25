import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';

import 'get_spots_test.mocks.dart';

@GenerateMocks([SpotRepository])
void main() {
  late MockSpotRepository mockRepo;
  late GetSpots usecase;

  final wantToGoSpot = Spot(
    id: 'spot-1',
    title: 'カフェ',
    latitude: 35.0,
    longitude: 139.0,
    status: SpotStatus.wantToGo,
    createdAt: DateTime(2024, 1, 1),
  );
  final visitedSpot = Spot(
    id: 'spot-2',
    title: '公園',
    latitude: 35.1,
    longitude: 139.1,
    status: SpotStatus.visited,
    createdAt: DateTime(2024, 1, 2),
  );

  setUp(() {
    mockRepo = MockSpotRepository();
    usecase = GetSpots(mockRepo);
    when(mockRepo.getSpots())
        .thenAnswer((_) => Stream.value([wantToGoSpot, visitedSpot]));
  });

  group('GetSpots', () {
    test('filter なしで全スポットを返す', () async {
      final result = await usecase.call().first;
      expect(result.length, 2);
    });

    test('wantToGo フィルタで wantToGo のみ返す', () async {
      final result = await usecase.call(filter: SpotStatus.wantToGo).first;
      expect(result.length, 1);
      expect(result.first.status, SpotStatus.wantToGo);
    });

    test('visited フィルタで visited のみ返す', () async {
      final result = await usecase.call(filter: SpotStatus.visited).first;
      expect(result.length, 1);
      expect(result.first.status, SpotStatus.visited);
    });

    test('一致するスポットがなければ空リストを返す', () async {
      when(mockRepo.getSpots()).thenAnswer((_) => Stream.value([wantToGoSpot]));

      final result = await usecase.call(filter: SpotStatus.visited).first;

      expect(result, isEmpty);
    });
  });
}
