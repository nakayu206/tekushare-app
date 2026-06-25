import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';

import 'walk_session_provider_test.mocks.dart';

@GenerateMocks([WalkSessionRepository, RouteRepository])
void main() {
  late MockWalkSessionRepository mockSessionRepo;
  late MockRouteRepository mockRouteRepo;

  setUp(() {
    mockSessionRepo = MockWalkSessionRepository();
    mockRouteRepo = MockRouteRepository();
    when(mockSessionRepo.saveSession(any))
        .thenAnswer((_) => Future<void>.value());
    when(mockRouteRepo.saveRoute(any)).thenAnswer((_) => Future<void>.value());
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        walkSessionRepositoryProvider.overrideWithValue(mockSessionRepo),
        routeRepositoryProvider.overrideWithValue(mockRouteRepo),
      ],
    );
  }

  WalkRoute makeRoute() => WalkRoute(
        id: 'route-1',
        walkSessionId: 'session-1',
        points: [const LatLng(35.0, 139.0)],
        createdAt: DateTime(2024, 1, 1),
      );

  group('WalkSessionNotifier', () {
    test('初期状態は idle', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.idle);
    });

    test('startWalk で walking 状態になる', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(walkSessionProvider.notifier).startWalk();

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.walking);
      expect(session.startedAt, isNotNull);
    });

    test('endWalk で finished 状態になる', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(walkSessionProvider.notifier).startWalk();
      await container.read(walkSessionProvider.notifier).endWalk(makeRoute());

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.finished);
      expect(session.finishedAt, isNotNull);
    });

    test('endWalk で saveSession が呼ばれる', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(walkSessionProvider.notifier).startWalk();
      await container.read(walkSessionProvider.notifier).endWalk(makeRoute());

      verify(mockSessionRepo.saveSession(any)).called(1);
    });

    test('endWalk で saveRoute が呼ばれる', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(walkSessionProvider.notifier).startWalk();
      await container.read(walkSessionProvider.notifier).endWalk(makeRoute());

      verify(mockRouteRepo.saveRoute(any)).called(1);
    });
  });
}
