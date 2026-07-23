import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences.setMockInitialValues({});
    mockSessionRepo = MockWalkSessionRepository();
    mockRouteRepo = MockRouteRepository();
    when(mockSessionRepo.saveSession(any))
        .thenAnswer((_) => Future<void>.value());
    when(mockRouteRepo.saveRoute(any)).thenAnswer((_) => Future<void>.value());
  });

  Future<ProviderContainer> makeContainer({
    Map<String, Object> prefsData = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefsData);
    final container = ProviderContainer(
      overrides: [
        walkSessionRepositoryProvider.overrideWithValue(mockSessionRepo),
        routeRepositoryProvider.overrideWithValue(mockRouteRepo),
      ],
    );
    // sharedPrefsProvider (FutureProvider) を先に解決しておく
    await container.read(sharedPrefsProvider.future);
    return container;
  }

  WalkRoute makeRoute() => WalkRoute(
        id: 'route-1',
        walkSessionId: 'session-1',
        points: [const LatLng(35.0, 139.0)],
        createdAt: DateTime(2024, 1, 1),
      );

  group('WalkSessionNotifier', () {
    test('初期状態は idle', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.idle);
    });

    test('startWalk で walking 状態になる', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container.read(walkSessionProvider.notifier).startWalk();

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.walking);
      expect(session.startedAt, isNotNull);
    });

    test('endWalk で finished 状態になる', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container.read(walkSessionProvider.notifier).startWalk();
      await container.read(walkSessionProvider.notifier).endWalk(makeRoute());

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.finished);
      expect(session.finishedAt, isNotNull);
    });

    test('endWalk で saveSession が呼ばれる', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container.read(walkSessionProvider.notifier).startWalk();
      await container.read(walkSessionProvider.notifier).endWalk(makeRoute());

      verify(mockSessionRepo.saveSession(any)).called(1);
    });

    test('endWalk で saveRoute が呼ばれる', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container.read(walkSessionProvider.notifier).startWalk();
      await container.read(walkSessionProvider.notifier).endWalk(makeRoute());

      verify(mockRouteRepo.saveRoute(any)).called(1);
    });

    test('idle 状態で endWalk を呼んでもリポジトリが呼ばれない', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container.read(walkSessionProvider.notifier).endWalk(makeRoute());

      verifyNever(mockSessionRepo.saveSession(any));
      verifyNever(mockRouteRepo.saveRoute(any));
    });

    test('walking 状態が SharedPreferences に保存されていたら起動時に復元される', () async {
      final container = await makeContainer(prefsData: {
        'walk_id': 'restored_id',
        'walk_status': WalkStatus.walking.index,
        'walk_started_at': DateTime.now().millisecondsSinceEpoch,
        'walk_elapsed': 120,
      });
      addTearDown(container.dispose);

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.walking);
      expect(session.id, 'restored_id');
      expect(session.elapsedSeconds, 120);
    });

    test('SharedPreferences の状態が idle なら起動時は idle になる', () async {
      final container = await makeContainer(prefsData: {
        'walk_id': 'old_id',
        'walk_status': WalkStatus.idle.index,
      });
      addTearDown(container.dispose);

      final session = container.read(walkSessionProvider);
      expect(session.status, WalkStatus.idle);
    });
  });
}
