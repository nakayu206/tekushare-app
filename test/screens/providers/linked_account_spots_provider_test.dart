import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/account_link_repository.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/linked_account_spots_provider.dart';

import 'linked_account_spots_provider_test.mocks.dart';

@GenerateMocks([AccountLinkRepository])
void main() {
  late MockAccountLinkRepository mockRepo;

  final wantToGoSpot = Spot(
    id: 'spot-1',
    title: 'お気に入り公園',
    latitude: 35.0,
    longitude: 139.0,
    status: SpotStatus.wantToGo,
    createdAt: DateTime(2024, 1, 1),
    category: '公園',
  );

  final visitedSpot = Spot(
    id: 'spot-2',
    title: '駅前カフェ',
    latitude: 35.1,
    longitude: 139.1,
    status: SpotStatus.visited,
    createdAt: DateTime(2024, 1, 2),
    category: 'カフェ',
  );

  setUp(() {
    mockRepo = MockAccountLinkRepository();
    when(mockRepo.watchLinkedAccounts())
        .thenAnswer((_) => const Stream.empty());
  });

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        accountLinkRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  group('linkedAccountSpotsProvider', () {
    test('両方共有ONのとき wantToGoSpots と visitedSpots を返す', () async {
      when(mockRepo.fetchShareSettings('uid-other')).thenAnswer(
        (_) async => (shareWantToGo: true, shareVisited: true),
      );
      when(mockRepo.fetchSharedSpots(
        'uid-other',
        shareWantToGo: true,
        shareVisited: true,
      )).thenAnswer((_) async => [wantToGoSpot, visitedSpot]);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(linkedAccountSpotsProvider('uid-other').future);

      expect(result.wantToGoSpots, [wantToGoSpot]);
      expect(result.visitedSpots, [visitedSpot]);
    });

    test(
        'shareWantToGo=false のとき fetchSharedSpots はvisitedのみで呼ばれ wantToGoSpots は空',
        () async {
      when(mockRepo.fetchShareSettings('uid-other')).thenAnswer(
        (_) async => (shareWantToGo: false, shareVisited: true),
      );
      when(mockRepo.fetchSharedSpots(
        'uid-other',
        shareWantToGo: false,
        shareVisited: true,
      )).thenAnswer((_) async => [visitedSpot]);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(linkedAccountSpotsProvider('uid-other').future);

      expect(result.wantToGoSpots, isEmpty);
      expect(result.visitedSpots, [visitedSpot]);
    });

    test(
        'shareVisited=false のとき fetchSharedSpots はwantToGoのみで呼ばれ visitedSpots は空',
        () async {
      when(mockRepo.fetchShareSettings('uid-other')).thenAnswer(
        (_) async => (shareWantToGo: true, shareVisited: false),
      );
      when(mockRepo.fetchSharedSpots(
        'uid-other',
        shareWantToGo: true,
        shareVisited: false,
      )).thenAnswer((_) async => [wantToGoSpot]);

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(linkedAccountSpotsProvider('uid-other').future);

      expect(result.wantToGoSpots, [wantToGoSpot]);
      expect(result.visitedSpots, isEmpty);
    });

    test('両方共有OFF のとき fetchSharedSpots を呼ばずに空を返す', () async {
      when(mockRepo.fetchShareSettings('uid-other')).thenAnswer(
        (_) async => (shareWantToGo: false, shareVisited: false),
      );

      final container = buildContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(linkedAccountSpotsProvider('uid-other').future);

      verifyNever(mockRepo.fetchSharedSpots(
        any,
        shareWantToGo: anyNamed('shareWantToGo'),
        shareVisited: anyNamed('shareVisited'),
      ));
      expect(result.wantToGoSpots, isEmpty);
      expect(result.visitedSpots, isEmpty);
    });
  });
}
