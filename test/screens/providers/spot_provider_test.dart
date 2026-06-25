import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';

import 'spot_provider_test.mocks.dart';

@GenerateMocks([SpotRepository, PhotoRepository])
void main() {
  late MockSpotRepository mockSpotRepo;
  late MockPhotoRepository mockPhotoRepo;

  final fakeSpot = Spot(
    id: 'spot-1',
    title: 'カフェ',
    latitude: 35.0,
    longitude: 139.0,
    status: SpotStatus.wantToGo,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockSpotRepo = MockSpotRepository();
    mockPhotoRepo = MockPhotoRepository();
    when(mockSpotRepo.getSpots()).thenAnswer((_) => Stream.value([fakeSpot]));
    when(mockSpotRepo.saveSpot(any)).thenAnswer((_) => Future<void>.value());
    when(mockSpotRepo.updateSpotStatus(any, any))
        .thenAnswer((_) => Future<void>.value());
    when(mockPhotoRepo.attachPhoto(any, any))
        .thenAnswer((_) => Future<void>.value());
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        spotRepositoryProvider.overrideWithValue(mockSpotRepo),
        photoRepositoryProvider.overrideWithValue(mockPhotoRepo),
      ],
    );
  }

  group('SpotNotifier', () {
    test('初期状態でリポジトリから spots を購読する', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      final spots = container.read(spotProvider);
      expect(spots, [fakeSpot]);
    });

    test('saveSpot で saveSpot が呼ばれる', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(spotProvider.notifier).saveSpot(
            title: 'カフェ',
            latitude: 35.0,
            longitude: 139.0,
          );

      verify(mockSpotRepo.saveSpot(any)).called(1);
    });

    test('updateStatus で updateSpotStatus が呼ばれる', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(spotProvider.notifier)
          .updateStatus('spot-1', SpotStatus.visited);

      verify(mockSpotRepo.updateSpotStatus('spot-1', SpotStatus.visited))
          .called(1);
    });

    test('attachPhoto で attachPhoto が呼ばれる', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(spotProvider.notifier)
          .attachPhoto('spot-1', '/img/photo.jpg');

      verify(mockPhotoRepo.attachPhoto('spot-1', '/img/photo.jpg')).called(1);
    });
  });

  group('filteredSpotsProvider', () {
    test('filter なしで全件返す', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await Future<void>.delayed(Duration.zero);
      final result = container.read(filteredSpotsProvider);
      expect(result, [fakeSpot]);
    });

    test('wantToGo フィルタで wantToGo のみ返す', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(selectedSpotStatusProvider.notifier).state =
          SpotStatus.wantToGo;
      await Future<void>.delayed(Duration.zero);

      final result = container.read(filteredSpotsProvider);
      expect(result.every((s) => s.status == SpotStatus.wantToGo), isTrue);
    });

    test('visited フィルタで visited のみ返す', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(selectedSpotStatusProvider.notifier).state =
          SpotStatus.visited;
      await Future<void>.delayed(Duration.zero);

      final result = container.read(filteredSpotsProvider);
      expect(result, isEmpty);
    });
  });
}
