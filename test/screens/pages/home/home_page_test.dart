import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/walk/view/walk_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/clock_provider.dart';
import 'package:tekushare/screens/providers/location_provider.dart';

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

void main() {
  group('HomePage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Stream.periodic のタイマーがテスト後に残らないよう単発に差し替え
            clockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
            walkSessionRepositoryProvider
                .overrideWithValue(_FakeWalkSessionRepository()),
            routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
            // WalkPage の CircularProgressIndicator で pumpAndSettle がタイムアウトしないよう静的ストリームに差し替え
            locationProvider.overrideWith(
              (ref) => Stream<Position>.error(Exception('GPS unavailable')),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      // アニメーション（2800ms）を完了させてボタンを操作可能にする
      await tester.pump(const Duration(seconds: 3));
    }

    // 散歩をはじめるボタンをタップすると WalkPage へ遷移する
    testWidgets('navigates to WalkPage when start walk button is tapped',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.startWalk));
      await tester.pumpAndSettle();

      expect(find.byType(WalkPage), findsOneWidget);
    });

    // ボトムナビのリストをタップすると SpotListPage へ遷移する
    testWidgets('navigates to SpotListPage when bottom nav list is tapped',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsOneWidget);
    });
  });
}
