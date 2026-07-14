import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/photo/remove_photo_from_spot.dart';
import 'package:tekushare/domain/usecases/spot/delete_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/walk/view/walk_page.dart';
import 'package:tekushare/app.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/clock_provider.dart';
import 'package:tekushare/screens/providers/contact_provider.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';

class _FakeSaveSpot implements SaveSpot {
  const _FakeSaveSpot();
  @override
  Future<String> call({
    required String title,
    required double latitude,
    required double longitude,
    String? memo,
    String? category,
    SpotStatus status = SpotStatus.wantToGo,
  }) async =>
      'fake-id';
}

class _FakeGetSpots implements GetSpots {
  const _FakeGetSpots();
  @override
  Stream<List<Spot>> call({SpotStatus? filter}) => Stream.value(const []);
}

class _FakeUpdateSpotStatus implements UpdateSpotStatus {
  const _FakeUpdateSpotStatus();
  @override
  Future<void> call(String spotId, SpotStatus status) async {}
}

class _FakeAttachPhotoToSpot implements AttachPhotoToSpot {
  const _FakeAttachPhotoToSpot();
  @override
  Future<String> call(String spotId, String imagePath) async => imagePath;
}

class _FakeRemovePhotoFromSpot implements RemovePhotoFromSpot {
  const _FakeRemovePhotoFromSpot();
  @override
  Future<void> call(String spotId, String imagePath) async {}
}

class _FakeUpdateSpot implements UpdateSpot {
  const _FakeUpdateSpot();
  @override
  Future<void> call(Spot spot) async {}
}

class _FakeDeleteSpot implements DeleteSpot {
  const _FakeDeleteSpot();
  @override
  Future<void> call(String id) async {}
}

final _spotOverride = spotProvider.overrideWith(
  (ref) => SpotNotifier(
    saveSpot: const _FakeSaveSpot(),
    getSpots: const _FakeGetSpots(),
    updateSpot: const _FakeUpdateSpot(),
    updateSpotStatus: const _FakeUpdateSpotStatus(),
    attachPhotoToSpot: const _FakeAttachPhotoToSpot(),
    removePhotoFromSpot: const _FakeRemovePhotoFromSpot(),
    deleteSpot: const _FakeDeleteSpot(),
  ),
);

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
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
          ],
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

    // ボトムナビのルートをタップすると WalkRoutePage へ遷移する
    testWidgets('navigates to WalkRoutePage when bottom nav route is tapped',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.navRoute));
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // ボトムナビの設定をタップすると SettingsPage へ遷移する
    testWidgets('navigates to SettingsPage when bottom nav settings is tapped',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.navSettings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    // 散歩中に別ページからホームに戻ると WalkPage へ自動遷移する
    testWidgets('didPopNext navigates to WalkPage when walk session is active',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
            walkSessionRepositoryProvider
                .overrideWithValue(_FakeWalkSessionRepository()),
            routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
            locationProvider.overrideWith(
              (ref) => Stream<Position>.error(Exception('GPS unavailable')),
            ),
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            navigatorKey: navKey,
            navigatorObservers: [routeObserver],
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
      await tester.pump(const Duration(seconds: 3));

      // ProviderScope のコンテナから walkSession を起動する
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomePage)),
      );
      container.read(walkSessionProvider.notifier).startWalk();

      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('dummy')),
        ),
      );
      await tester.pumpAndSettle();

      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.byType(WalkPage), findsOneWidget);
    });
  });
}
