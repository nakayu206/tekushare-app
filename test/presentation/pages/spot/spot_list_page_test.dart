import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/presentation/pages/spot/spot_detail_page.dart';
import 'package:tekushare/presentation/pages/spot/spot_list_page.dart';
import 'package:tekushare/presentation/widgets/common/app_bottom_nav.dart';

void main() {
  group('SpotListPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: SpotListPage()),
      );
      await tester.pump();
    }

    // 行きたいリストにのみ存在するアイテム
    const wantToGoOnly = 'ひだまりパーク';
    // 行ったリストにのみ存在するアイテム
    const wentOnly = '新宿御苑';

    testWidgets('ページタイトル「リスト」が表示される', (tester) async {
      await pumpPage(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.navList),
        ),
        findsOneWidget,
      );
    });

    testWidgets('「行きたい！」「行った！」の2つのタブが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGo), findsOneWidget);
      expect(find.text(AppStrings.listWentTab), findsOneWidget);
    });

    testWidgets('初期状態で「行きたい！」タブが選択されている', (tester) async {
      await pumpPage(tester);

      // 行きたい専用アイテムが表示され、行った専用アイテムは非表示
      expect(find.text(wantToGoOnly), findsOneWidget);
      expect(find.text(wentOnly), findsNothing);
    });

    testWidgets('「行った！」タブをタップすると行った一覧に切り替わる', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.listWentTab));
      await tester.pump();

      // 行った専用アイテムが表示され、行きたい専用アイテムは非表示
      expect(find.text(wentOnly), findsOneWidget);
      expect(find.text(wantToGoOnly), findsNothing);
    });

    testWidgets('6つのカテゴリチップが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.categoryPark), findsOneWidget);
      expect(find.text(AppStrings.categoryCafe), findsOneWidget);
      expect(find.text(AppStrings.categoryLunch), findsOneWidget);
      expect(find.text(AppStrings.categoryDinner), findsOneWidget);
      expect(find.text(AppStrings.categoryGoods), findsOneWidget);
      expect(find.text(AppStrings.categoryOther), findsOneWidget);
    });

    testWidgets('カテゴリチップをタップすると選択状態が変わる', (tester) async {
      await pumpPage(tester);

      // 初期は公園が選択色
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

      // カフェが選択色になり、公園は非選択色になる
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

    testWidgets('一覧に日付と矢印アイコンが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text('4/12'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('ボトムナビが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets('AppBarに戻るボタンが表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('行った！タブから行きたい！タブに戻れる', (tester) async {
      await pumpPage(tester);

      // 行った！タブに切り替え
      await tester.tap(find.text(AppStrings.listWentTab));
      await tester.pump();
      expect(find.text(wentOnly), findsOneWidget);

      // 行きたい！タブに戻す
      await tester.tap(find.text(AppStrings.wantToGo));
      await tester.pump();

      expect(find.text(wantToGoOnly), findsOneWidget);
      expect(find.text(wentOnly), findsNothing);
    });

    testWidgets('ボトムナビのホームをタップすると前の画面に戻る', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
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
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      expect(find.byType(SpotListPage), findsOneWidget);

      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsNothing);
    });

    testWidgets('リストアイテムをタップすると SpotDetailPage へ遷移する', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(wantToGoOnly));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsOneWidget);
    });

    testWidgets('「行った！」タブのアイテムをタップすると行った！モードで SpotDetailPage へ遷移する',
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
