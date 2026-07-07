import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/photo/remove_photo_from_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_detail_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
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
  const _FakeGetSpots(this._spots);
  final List<Spot> _spots;
  @override
  Stream<List<Spot>> call({SpotStatus? filter}) => Stream.value(_spots);
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

final _fakeSpots = [
  Spot(
    id: '1',
    title: 'ひだまりパーク',
    latitude: 0,
    longitude: 0,
    status: SpotStatus.wantToGo,
    createdAt: DateTime(2024, 4, 12),
  ),
  Spot(
    id: '2',
    title: 'Cafe&Gallery',
    latitude: 0,
    longitude: 0,
    status: SpotStatus.wantToGo,
    createdAt: DateTime(2024, 5, 12),
  ),
  Spot(
    id: '8',
    title: '新宿御苑',
    latitude: 0,
    longitude: 0,
    status: SpotStatus.visited,
    createdAt: DateTime(2024, 1, 15),
  ),
];

final _spotOverride = spotProvider.overrideWith(
  (ref) => SpotNotifier(
    saveSpot: const _FakeSaveSpot(),
    getSpots: _FakeGetSpots(_fakeSpots),
    updateSpotStatus: const _FakeUpdateSpotStatus(),
    attachPhotoToSpot: const _FakeAttachPhotoToSpot(),
    removePhotoFromSpot: const _FakeRemovePhotoFromSpot(),
  ),
);

void main() {
  group('SpotListPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [_spotOverride],
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
            home: const SpotListPage(),
          ),
        ),
      );
      await tester.pump();
    }

    // 行きたいリストにのみ存在するアイテム
    const wantToGoOnly = 'ひだまりパーク';
    // 行ったリストにのみ存在するアイテム
    const wentOnly = '新宿御苑';

    // ページタイトル「リスト」が表示される
    testWidgets('shows page title', (tester) async {
      await pumpPage(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.navList),
        ),
        findsOneWidget,
      );
    });

    // 「行きたい！」「行った！」の2つのタブが表示される
    testWidgets('shows two tabs', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGo), findsOneWidget);
      expect(find.text(AppStrings.listWentTab), findsOneWidget);
    });

    // 初期状態で「行きたい！」タブが選択されている
    testWidgets('want-to-go tab is selected by default', (tester) async {
      await pumpPage(tester);

      expect(find.text(wantToGoOnly), findsOneWidget);
      expect(find.text(wentOnly), findsNothing);
    });

    // 「行った！」タブをタップすると行った一覧に切り替わる
    testWidgets('tapping went tab switches to went list', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.listWentTab));
      await tester.pump();

      expect(find.text(wentOnly), findsOneWidget);
      expect(find.text(wantToGoOnly), findsNothing);
    });

    // 6つのカテゴリチップが表示される
    testWidgets('shows six category chips', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.categoryPark), findsOneWidget);
      expect(find.text(AppStrings.categoryCafe), findsOneWidget);
      expect(find.text(AppStrings.categoryLunch), findsOneWidget);
      expect(find.text(AppStrings.categoryDinner), findsOneWidget);
      expect(find.text(AppStrings.categoryGoods), findsOneWidget);
      expect(find.text(AppStrings.categoryOther), findsOneWidget);
    });

    // カテゴリチップをタップすると選択状態が変わる
    testWidgets('tapping a category chip changes selection state',
        (tester) async {
      await pumpPage(tester);

      expect(
        find.ancestor(
          of: find.text(AppStrings.categoryPark),
          matching: find.byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == AppColors.listSelected),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(AppStrings.categoryCafe));
      await tester.pump();

      expect(
        find.ancestor(
          of: find.text(AppStrings.categoryCafe),
          matching: find.byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == AppColors.listSelected),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text(AppStrings.categoryPark),
          matching: find.byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == AppColors.listSelected),
        ),
        findsNothing,
      );
    });

    // 一覧に日付と矢印アイコンが表示される
    testWidgets('shows date and arrow icon in list', (tester) async {
      await pumpPage(tester);

      expect(find.text('04/12'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    // スポットが空のときは空状態メッセージが表示される
    testWidgets('shows empty message when no spots in current tab',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final emptyOverride = spotProvider.overrideWith(
        (ref) => SpotNotifier(
          saveSpot: const _FakeSaveSpot(),
          getSpots: const _FakeGetSpots([]),
          updateSpotStatus: const _FakeUpdateSpotStatus(),
          attachPhotoToSpot: const _FakeAttachPhotoToSpot(),
          removePhotoFromSpot: const _FakeRemovePhotoFromSpot(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [emptyOverride],
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
            home: const SpotListPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.spotListEmpty), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // AppBarに戻るボタンが表示される
    testWidgets('shows back button in AppBar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [_spotOverride],
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
                  MaterialPageRoute(builder: (_) => const SpotListPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
    });

    // 行った！タブから行きたい！タブに戻れる
    testWidgets('can switch back to want-to-go tab from went tab',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.listWentTab));
      await tester.pump();
      expect(find.text(wentOnly), findsOneWidget);

      await tester.tap(find.text(AppStrings.wantToGo));
      await tester.pump();

      expect(find.text(wantToGoOnly), findsOneWidget);
      expect(find.text(wentOnly), findsNothing);
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
          overrides: [_spotOverride],
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
                  MaterialPageRoute(builder: (_) => const SpotListPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      expect(find.byType(SpotListPage), findsOneWidget);

      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsNothing);
    });

    // ボトムナビのルートをタップすると WalkRoutePage へ遷移する
    testWidgets('tapping bottom nav route navigates to WalkRoutePage',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [_spotOverride],
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
                  MaterialPageRoute(builder: (_) => const SpotListPage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navRoute));
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
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
          overrides: [_spotOverride],
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
                  MaterialPageRoute(builder: (_) => const SpotListPage()),
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

    // リストアイテムをタップすると SpotDetailPage へ遷移する
    testWidgets('tapping a list item navigates to SpotDetailPage',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(wantToGoOnly));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsOneWidget);
    });

    // 「行った！」タブのアイテムをタップすると行った！モードで SpotDetailPage へ遷移する
    testWidgets(
        'tapping an item in went tab navigates to SpotDetailPage in went mode',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.listWentTab));
      await tester.pump();
      await tester.tap(find.text(wentOnly));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.listWentTab),
        ),
        findsOneWidget,
      );
    });
  });
}
