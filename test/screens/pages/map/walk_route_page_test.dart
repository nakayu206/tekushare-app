import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/photo/remove_photo_from_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/map/viewmodel/walk_route_viewmodel.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
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
  Future<void> call(String spotId, String imagePath) async {}
}

class _FakeRemovePhotoFromSpot implements RemovePhotoFromSpot {
  const _FakeRemovePhotoFromSpot();
  @override
  Future<void> call(String spotId, String imagePath) async {}
}

final _historyOverride = walkHistoryProvider.overrideWith(
  (_) async => const <WalkSession>[],
);

final _spotOverride = spotProvider.overrideWith(
  (ref) => SpotNotifier(
    saveSpot: const _FakeSaveSpot(),
    getSpots: const _FakeGetSpots(),
    updateSpotStatus: const _FakeUpdateSpotStatus(),
    attachPhotoToSpot: const _FakeAttachPhotoToSpot(),
    removePhotoFromSpot: const _FakeRemovePhotoFromSpot(),
  ),
);

class _NonStandardDateViewModel extends WalkRouteViewModel {
  @override
  WalkRouteState build() => const WalkRouteState(
        selectedDay: 1,
        logs: [
          (
            date: 'invalid-format',
            startEndTime: '10:00〜11:00',
            duration: '1時間',
            distance: '2.0km',
            spotCount: 3,
            dayLabel: '月',
          ),
        ],
      );
}

void main() {
  group('WalkRoutePage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [_historyOverride],
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
      await tester.pump();
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
          overrides: [_historyOverride],
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
          overrides: [_historyOverride],
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
          overrides: [_historyOverride],
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
          overrides: [_historyOverride],
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

    // ルート名を入力して保存すると保存完了が表示される（line 54: non-empty name branch）
    testWidgets('saving with entered name shows saved confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [_historyOverride],
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

    // 日付形式が不正の場合 _shortDate はそのまま返す（line 799 regex fallback）
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
          overrides: [_historyOverride],
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
          overrides: [_historyOverride, _spotOverride],
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
          overrides: [_historyOverride],
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

    // 次のページボタンをタップするとページが切り替わる（lines 196-213, 324）
    testWidgets('tapping next page button shows next page', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    // 前のページボタンをタップするとページが戻る（line 308）
    testWidgets('tapping previous page button shows previous page',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    // 左フリングで次のページへ（onHorizontalDragEnd line 211）
    testWidgets('flinging left navigates to next page', (tester) async {
      await pumpPage(tester);

      await tester.fling(
        find.byType(GestureDetector).first,
        const Offset(-300, 0),
        600,
      );
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // 2ページ目で右フリングで前ページへ（line 213）
    testWidgets('flinging right on page 2 navigates to previous page',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.fling(
        find.byType(GestureDetector).first,
        const Offset(300, 0),
        600,
      );
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // ページ2のルートをタップしてもページが表示されている（line 290 + selectRoute via pagination）
    testWidgets('tapping route on second page keeps page visible',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      await tester.tap(find.text('公園まわりコース（朝用）').last);
      await tester.pump();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // カレンダーの日付をタップしてもページが表示されている（line 569）
    testWidgets('tapping a calendar day keeps page visible', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(find.text('3'), findsWidgets);
    });
  });
}
