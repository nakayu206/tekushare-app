import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/pages/walk/view/walk_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/clock_provider.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
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

/// 共通のプロバイダーオーバーライド（clockProvider のタイマーを回避）
List<Override> get _baseOverrides => [
      // Stream.periodic によるタイマーをテストで残さないよう単発ストリームに差し替え
      clockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
      walkSessionRepositoryProvider
          .overrideWithValue(_FakeWalkSessionRepository()),
      routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
      // WalkPage の CircularProgressIndicator で pumpAndSettle がタイムアウトしないよう静的ストリームに差し替え
      locationProvider.overrideWith(
        (ref) => Stream<Position>.error(Exception('GPS unavailable')),
      ),
    ];

void main() {
  AppConfig.setFlavor(Flavor.dev);

  group('HomePage', () {
    testWidgets('初期状態でホーム画面が表示される', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides,
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const HomePage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('散歩を始めるボタン押下でセッションが walking 状態になる', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(overrides: _baseOverrides);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const HomePage(),
          ),
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
      // WalkPage のコンテンツが収まるよう縦に広いサイズを指定
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(overrides: _baseOverrides);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const HomePage(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 3000));

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(WalkPage), findsOneWidget);
    });

    testWidgets('walking 状態のまま戻って再度ボタンを押しても WalkPage へ遷移する', (tester) async {
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(overrides: _baseOverrides);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const HomePage(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 3000));

      // 1回目：WalkPage へ遷移
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();
      expect(find.byType(WalkPage), findsOneWidget);

      // WalkPage から戻る（walking 状態のまま）
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      // 2回目：再度ボタンを押しても WalkPage へ遷移する
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();
      expect(find.byType(WalkPage), findsOneWidget);
    });
  });
}
