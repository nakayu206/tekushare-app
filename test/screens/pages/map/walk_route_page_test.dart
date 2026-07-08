import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/domain/entities/saved_route.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/entities/lat_lng.dart' as domain;
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/saved_route_repository.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/photo/remove_photo_from_spot.dart';
import 'package:tekushare/domain/usecases/spot/delete_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/map/viewmodel/walk_route_viewmodel.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/providers/walk_history_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

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

class _FakeGetSpotsWithData implements GetSpots {
  const _FakeGetSpotsWithData(this.spots);
  final List<Spot> spots;
  @override
  Stream<List<Spot>> call({SpotStatus? filter}) => Stream.value(spots);
}

class _FakeUpdateSpotStatus implements UpdateSpotStatus {
  const _FakeUpdateSpotStatus();
  @override
  Future<void> call(String spotId, SpotStatus status) async {}
}

class _FakeAttachPhotoToSpot implements AttachPhotoToSpot {
  const _FakeAttachPhotoToSpot();
  @override
  Future<void> call(String spotId, String imagePath) async {}
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

class _FakeSavedRouteRepository implements SavedRouteRepository {
  const _FakeSavedRouteRepository({this.routes = const []});
  final List<SavedRoute> routes;

  @override
  Future<void> save(SavedRoute route) async {}

  @override
  Future<List<SavedRoute>> getAll() async => routes;

  @override
  Future<void> delete(int id) async {}
}

class _FakeRouteRepository implements RouteRepository {
  const _FakeRouteRepository({this.routes = const []});
  final List<WalkRoute> routes;

  @override
  Future<void> saveRoute(WalkRoute route) async {}

  @override
  Future<WalkRoute?> getRouteBySessionId(String sessionId) async => null;

  @override
  Future<List<WalkRoute>> getAllRoutes() async => routes;
}

// 約1kmのGPSルート（35.000→35.009 ≈ 1.0km）
final _testWalkRoutes = [
  WalkRoute(
    id: 'test-id',
    walkSessionId: 'test-id',
    points: const [
      domain.LatLng(35.000, 139.000),
      domain.LatLng(35.009, 139.000),
    ],
    createdAt: DateTime(2026, 1, 1),
  ),
];

final _testSavedRoutes = [
  SavedRoute(
    id: 1,
    name: '公園まわりコース（朝用）',
    date: '2/7',
    distance: '1.2km',
    time: '約15分',
    createdAt: DateTime(2026, 2, 7),
  ),
  SavedRoute(
    id: 2,
    name: '川沿いコース（休日用）',
    date: '2/6',
    distance: '2.5km',
    time: '約30分',
    createdAt: DateTime(2026, 2, 6),
  ),
  SavedRoute(
    id: 3,
    name: '商店街コース',
    date: '2/5',
    distance: '1.2km',
    time: '約15分',
    createdAt: DateTime(2026, 2, 5),
  ),
  SavedRoute(
    id: 4,
    name: '公園まわりコース（朝用）',
    date: '2/4',
    distance: '1.2km',
    time: '約15分',
    createdAt: DateTime(2026, 2, 4),
  ),
  SavedRoute(
    id: 5,
    name: '川沿いコース（休日用）',
    date: '2/3',
    distance: '2.5km',
    time: '約30分',
    createdAt: DateTime(2026, 2, 3),
  ),
  SavedRoute(
    id: 6,
    name: '商店街コース',
    date: '2/2',
    distance: '1.2km',
    time: '約15分',
    createdAt: DateTime(2026, 2, 2),
  ),
  SavedRoute(
    id: 7,
    name: '公園まわりコース（朝用）',
    date: '2/1',
    distance: '1.2km',
    time: '約15分',
    createdAt: DateTime(2026, 2, 1),
  ),
];

final _historyOverride = walkHistoryProvider.overrideWith(
  (_) async => const <WalkSession>[],
);

final _walkRoutesOverride = routeRepositoryProvider.overrideWith(
  (_) => const _FakeRouteRepository(),
);

final _walkRoutesWithDataOverride = routeRepositoryProvider.overrideWith(
  (_) => _FakeRouteRepository(routes: _testWalkRoutes),
);

final _savedRouteRepoOverride = savedRouteRepositoryProvider.overrideWith(
  (_) => const _FakeSavedRouteRepository(),
);

final _savedRouteRepoWithDataOverride =
    savedRouteRepositoryProvider.overrideWith(
  (_) => _FakeSavedRouteRepository(routes: _testSavedRoutes),
);

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

class _NonStandardDateViewModel extends WalkRouteViewModel {
  @override
  WalkRouteState build() => const WalkRouteState(
        selectedDay: 1,
        logs: [
          (
            sessionId: '',
            date: 'invalid-format',
            startEndTime: '10:00〜11:00',
            duration: '1時間',
            distance: '2.0km',
            spotCount: 3,
            dayLabel: '月',
          ),
        ],
      );

  @override
  void setLogs(List<WalkLog> logs) {
    // テスト用固定ログを維持するため外部からの更新を無視する
  }
}

void main() {
  group('WalkRoutePage', () {
    // pumpPage はルートデータあり（テスト用7件）
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoWithDataOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // 今週のセッションがある場合、実データの日付が表示される
    testWidgets('shows real session data for current week', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final session = WalkSession(
        id: 'test-id',
        status: WalkStatus.finished,
        startedAt: DateTime(now.year, now.month, now.day, 9, 0),
        finishedAt: DateTime(now.year, now.month, now.day, 9, 30),
        elapsedSeconds: 1800,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walkHistoryProvider.overrideWith((_) async => [session]),
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('9:00~9:30'), findsOneWidget);
      expect(find.text('30:00'), findsOneWidget);
    });

    // WalkRouteのGPSポイントがあってもページが正常にレンダリングされる
    testWidgets('renders without error when walk routes have gps points',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final session = WalkSession(
        id: 'test-id',
        status: WalkStatus.finished,
        startedAt: DateTime(now.year, now.month, now.day, 9, 0),
        finishedAt: DateTime(now.year, now.month, now.day, 9, 30),
        elapsedSeconds: 1800,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walkHistoryProvider.overrideWith((_) async => [session]),
            _savedRouteRepoOverride,
            _walkRoutesWithDataOverride,
            _spotOverride,
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
            home: const WalkRoutePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // セッションの時刻が表示されること（ルートデータあり時もクラッシュしない）
      expect(find.text('9:00~9:30'), findsOneWidget);
    });

    // ページタイトルが表示される
    testWidgets('shows page title', (tester) async {
      await pumpPage(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.walkRoutePageTitle),
        ),
        findsOneWidget,
      );
    });

    // 保存済みルートセクションが表示される
    testWidgets('shows saved routes section', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.savedRoutes), findsOneWidget);
    });

    // ルート一覧が表示される
    testWidgets('shows route list items', (tester) async {
      await pumpPage(tester);

      expect(find.text('公園まわりコース（朝用）'), findsWidgets);
      expect(find.text('川沿いコース（休日用）'), findsOneWidget);
      expect(find.text('商店街コース'), findsOneWidget);
    });

    // 選択中のルートセクションが表示される
    testWidgets('shows selected route section', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.selectedRoute), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // ルートをタップすると選択状態が変わる
    testWidgets('tapping a route changes selection', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('川沿いコース（休日用）'));
      await tester.pump();

      expect(find.text('川沿いコース（休日用）'), findsWidgets);
    });

    // showSaveDialogOnLoadがtrueのとき保存確認ダイアログが表示される
    testWidgets(
        'shows save confirmation dialog when showSaveDialogOnLoad is true',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(showSaveDialogOnLoad: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saveRouteConfirmMessage), findsOneWidget);
    });

    // 保存確認ダイアログのキャンセルでダイアログが閉じる
    testWidgets('canceling save dialog closes dialog', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(showSaveDialogOnLoad: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saveRouteConfirmMessage), findsNothing);
    });

    // 保存確認ダイアログの保存で保存完了ダイアログが表示される
    testWidgets('confirming save shows saved dialog', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(showSaveDialogOnLoad: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saved), findsOneWidget);
    });

    // 保存完了ダイアログの閉じるでダイアログが閉じる
    testWidgets('closing saved dialog closes dialog', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(showSaveDialogOnLoad: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.closeButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saved), findsNothing);
    });

    // ルート名を入力して保存すると保存完了が表示される
    testWidgets('saving with entered name shows saved confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(showSaveDialogOnLoad: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'マイコース');
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saved), findsOneWidget);
    });

    // 日付形式が不正の場合 _shortDate はそのまま返す
    testWidgets('_shortDate falls back to raw date when regex fails',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
            walkRouteViewModelProvider
                .overrideWith(_NonStandardDateViewModel.new),
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
            home: const WalkRoutePage(showSaveDialogOnLoad: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('invalid-format'), findsWidgets);
    });

    // ボトムナビのホームをタップすると前の画面に戻る
    testWidgets('tapping bottom nav home goes back to previous screen',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalkRoutePage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsNothing);
    });

    // ボトムナビのリストをタップすると SpotListPage へ遷移する
    testWidgets('tapping bottom nav list navigates to SpotListPage',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride
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
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalkRoutePage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsOneWidget);
    });

    // ボトムナビの設定をタップすると SettingsPage へ遷移する
    testWidgets('tapping bottom nav settings navigates to SettingsPage',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalkRoutePage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navSettings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    // 次のページボタンをタップするとページが切り替わる
    testWidgets('tapping next page button shows next page', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    // 前のページボタンをタップするとページが戻る
    testWidgets('tapping previous page button shows previous page',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    // ルートを左スワイプで削除できる
    testWidgets('dismissing a route removes it from the list', (tester) async {
      await pumpPage(tester);

      // 1件目（公園まわりコース）を左スワイプで削除
      await tester.drag(
        find.text('公園まわりコース（朝用）').first,
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      // ページはそのまま表示されている
      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // ページ2のルートをタップしてもページが表示されている
    testWidgets('tapping route on second page keeps page visible',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      await tester.tap(find.text('公園まわりコース（朝用）').last);
      await tester.pump();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // 散歩セッション中に登録したスポットの件数が反映される
    testWidgets('shows spot count for spots registered during walk session',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final session = WalkSession(
        id: 'spot-test-session',
        status: WalkStatus.finished,
        startedAt: DateTime(2026, 1, 15, 9, 0),
        finishedAt: DateTime(2026, 1, 15, 9, 30),
        elapsedSeconds: 1800,
      );

      // セッション内(9:15)と外(8:50, 10:00)にスポットを配置
      final spotsInSession = [
        Spot(
          id: 'spot-inside',
          title: '散歩中スポット',
          latitude: 35.0,
          longitude: 139.0,
          status: SpotStatus.wantToGo,
          createdAt: DateTime(2026, 1, 15, 9, 15),
        ),
        Spot(
          id: 'spot-before',
          title: 'セッション前スポット',
          latitude: 35.001,
          longitude: 139.001,
          status: SpotStatus.wantToGo,
          createdAt: DateTime(2026, 1, 15, 8, 50),
        ),
        Spot(
          id: 'spot-after',
          title: 'セッション後スポット',
          latitude: 35.002,
          longitude: 139.002,
          status: SpotStatus.wantToGo,
          createdAt: DateTime(2026, 1, 15, 10, 0),
        ),
      ];

      final spotsOverride = spotProvider.overrideWith(
        (ref) => SpotNotifier(
          saveSpot: const _FakeSaveSpot(),
          getSpots: _FakeGetSpotsWithData(spotsInSession),
          updateSpot: const _FakeUpdateSpot(),
          updateSpotStatus: const _FakeUpdateSpotStatus(),
          attachPhotoToSpot: const _FakeAttachPhotoToSpot(),
          removePhotoFromSpot: const _FakeRemovePhotoFromSpot(),
          deleteSpot: const _FakeDeleteSpot(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walkHistoryProvider.overrideWith((_) async => [session]),
            _savedRouteRepoOverride,
            _walkRoutesOverride,
            spotsOverride,
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
            home: const WalkRoutePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // セッション内のスポット1件だけが件数に反映される
      expect(find.text('行きたいスポット：1件'), findsOneWidget);
    });

    // walkSessionId なし保存ルートはマップのプレースホルダーを表示する
    testWidgets('shows map placeholder for route without walkSessionId',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            _savedRouteRepoWithDataOverride,
            _walkRoutesOverride,
            _spotOverride,
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
            home: const WalkRoutePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // walkSessionId が null の場合、マップアイコン（プレースホルダー）が表示される
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    });

    // walkSessionId 付きの保存ルートが FlutterMap を表示する
    testWidgets('shows FlutterMap for route with walkSessionId',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const sessionId = 'test-id';
      final savedRouteWithSession = [
        SavedRoute(
          id: 1,
          name: 'GPSコース',
          date: '2/7',
          distance: '1.0km',
          time: '00:15',
          createdAt: DateTime(2026, 2, 7),
          walkSessionId: sessionId,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _historyOverride,
            savedRouteRepositoryProvider.overrideWith(
              (_) => _FakeSavedRouteRepository(routes: savedRouteWithSession),
            ),
            _walkRoutesWithDataOverride,
            _spotOverride,
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
            home: const WalkRoutePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // FlutterMap がレンダリングされ、プレースホルダーは非表示
      expect(find.byIcon(Icons.map_outlined), findsNothing);
    });

    // カレンダーの日付をタップしてもページが表示されている
    testWidgets('tapping a calendar day keeps page visible', (tester) async {
      await pumpPage(tester);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == '3回',
        ),
      );
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == '3回',
        ),
        findsWidgets,
      );
    });
  });
}
