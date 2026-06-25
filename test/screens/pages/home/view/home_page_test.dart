import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/pages/walk/view/walk_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';

class _FakeWalkSessionRepository implements WalkSessionRepository {
  @override
  Future<void> saveSession(WalkSession session) async {}
  @override
  Future<List<WalkSession>> getAllSessions() async => [];
  @override
  Future<WalkSession?> getSessionById(String id) async => null;
}

class _FakeRouteRepository implements RouteRepository {
  @override
  Future<void> saveRoute(WalkRoute route) async {}
  @override
  Future<WalkRoute?> getRouteBySessionId(String sessionId) async => null;
  @override
  Future<List<WalkRoute>> getAllRoutes() async => [];
}

Widget _buildTestApp({List<Override> overrides = const []}) {
  AppConfig.setFlavor(Flavor.dev);
  return ProviderScope(
    overrides: [
      walkSessionRepositoryProvider
          .overrideWithValue(_FakeWalkSessionRepository()),
      routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
      ...overrides,
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  group('HomePage', () {
    testWidgets('初期状態でホーム画面が表示される', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('散歩を始めるボタン押下でセッションが walking 状態になる', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          walkSessionRepositoryProvider
              .overrideWithValue(_FakeWalkSessionRepository()),
          routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomePage()),
        ),
      );
      // アニメーション完了まで進める
      await tester.pump(const Duration(milliseconds: 3000));

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();

      expect(
        container.read(walkSessionProvider).status,
        WalkStatus.walking,
      );
    });

    testWidgets('walking 状態になったら WalkPage へ遷移する', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          walkSessionRepositoryProvider
              .overrideWithValue(_FakeWalkSessionRepository()),
          routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 3000));

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(WalkPage), findsOneWidget);
    });
  });
}
