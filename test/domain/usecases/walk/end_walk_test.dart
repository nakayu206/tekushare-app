import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/domain/usecases/walk/end_walk.dart';

import 'end_walk_test.mocks.dart';

@GenerateMocks([WalkSessionRepository, RouteRepository])
void main() {
  late MockWalkSessionRepository mockSessionRepo;
  late MockRouteRepository mockRouteRepo;
  late EndWalk usecase;

  setUp(() {
    mockSessionRepo = MockWalkSessionRepository();
    mockRouteRepo = MockRouteRepository();
    usecase = EndWalk(mockSessionRepo, mockRouteRepo);

    when(mockSessionRepo.saveSession(any))
        .thenAnswer((_) => Future<void>.value());
    when(mockRouteRepo.saveRoute(any)).thenAnswer((_) => Future<void>.value());
  });

  WalkSession makeSession({DateTime? startedAt}) {
    return WalkSession(
      id: 'session-1',
      status: WalkStatus.walking,
      startedAt:
          startedAt ?? DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  WalkRoute makeRoute() {
    return WalkRoute(
      id: 'route-1',
      walkSessionId: 'session-1',
      points: [const LatLng(35.0, 139.0)],
      createdAt: DateTime.now(),
    );
  }

  group('EndWalk', () {
    test('finished ステータスのセッションを返す', () async {
      final result = await usecase.call(makeSession(), makeRoute());
      expect(result.status, WalkStatus.finished);
    });

    test('finishedAt が設定される', () async {
      final result = await usecase.call(makeSession(), makeRoute());
      expect(result.finishedAt, isNotNull);
    });

    test('elapsedSeconds が startedAt からの経過秒数になる', () async {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 5));
      final result =
          await usecase.call(makeSession(startedAt: startedAt), makeRoute());
      expect(result.elapsedSeconds, greaterThanOrEqualTo(299));
      expect(result.elapsedSeconds, lessThanOrEqualTo(301));
    });

    test('startedAt が null なら elapsedSeconds は 0', () async {
      const session = WalkSession(
        id: 'session-1',
        status: WalkStatus.walking,
      );
      final result = await usecase.call(session, makeRoute());
      expect(result.elapsedSeconds, 0);
    });

    test('saveSession が呼ばれる', () async {
      final session = makeSession();
      final route = makeRoute();
      await usecase.call(session, route);
      verify(mockSessionRepo.saveSession(any)).called(1);
    });

    test('saveRoute が呼ばれる', () async {
      await usecase.call(makeSession(), makeRoute());
      verify(mockRouteRepo.saveRoute(any)).called(1);
    });
  });
}
