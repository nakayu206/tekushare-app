import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
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
  );
}

void main() {
  AppConfig.setFlavor(Flavor.dev);

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  List<Override> baseOverrides() => [
        clockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        walkSessionRepositoryProvider
            .overrideWithValue(_FakeWalkSessionRepository()),
        routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
        locationProvider.overrideWith(
          (ref) => Stream<Position>.error(Exception('GPS unavailable')),
        ),
        sharedPrefsProvider.overrideWith((ref) async => prefs),
      ];

  Future<ProviderContainer> makeContainer() async {
    final container = ProviderContainer(overrides: baseOverrides());
    await container.read(sharedPrefsProvider.future);
    return container;
  }

  group('HomePage', () {
    testWidgets('初期状態でホーム画面が表示される', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = await makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('散歩を始めるボタン押下でセッションが walking 状態になる', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = await makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump(const Duration(milliseconds: 3000));

      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();

      expect(
        container.read(walkSessionProvider).status,
        WalkStatus.walking,
      );
    });

    testWidgets('walking 状態になったら WalkPage へ遷移する', (tester) async {
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = await makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
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

      final container = await makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
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

    testWidgets('プロセスキル後の復元: walking 状態で起動したら WalkPage へ自動遷移する',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // SharedPreferences に walking 状態を事前書き込み（プロセスキル後の再起動をシミュレート）
      SharedPreferences.setMockInitialValues({
        'walk_id': 'restored_walk_id',
        'walk_status': WalkStatus.walking.index,
        'walk_started_at': DateTime.now().millisecondsSinceEpoch,
        'walk_elapsed': 300,
      });
      final walkingPrefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(overrides: [
        clockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        walkSessionRepositoryProvider
            .overrideWithValue(_FakeWalkSessionRepository()),
        routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
        locationProvider.overrideWith(
          (ref) => Stream<Position>.error(Exception('GPS unavailable')),
        ),
        sharedPrefsProvider.overrideWith((ref) async => walkingPrefs),
      ]);
      addTearDown(container.dispose);
      // sharedPrefsProvider を先に解決しておく（walkSessionProvider が requireValue で参照するため）
      await container.read(sharedPrefsProvider.future);

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(WalkPage), findsOneWidget);
    });
  });
}
