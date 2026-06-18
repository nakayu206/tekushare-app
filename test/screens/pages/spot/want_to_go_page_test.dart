import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/spot/view/want_to_go_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  group('WantToGoPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: WantToGoPage()),
        ),
      );
      await tester.pump();
    }

    // ページタイトルが表示される
    testWidgets('shows page title', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGoPageTitle), findsOneWidget);
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

    // 写真を追加ボタンが表示される
    testWidgets('shows add photo button', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.addPhoto), findsOneWidget);
    });

    // 保存ボタンが表示される
    testWidgets('shows save button', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGoSave), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // カテゴリチップをタップすると選択状態が変わる
    testWidgets('tapping a category chip changes selection state',
        (tester) async {
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

      // カフェが選択色になる
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
    });

    // 保存ボタンを押すと確認ダイアログが表示される
    testWidgets('pressing save button shows confirmation dialog',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoConfirmMessage), findsOneWidget);
    });

    // タイトル未入力時の確認ダイアログに（タイトルなし）が表示される
    testWidgets(
        'confirmation dialog shows no-title placeholder when title is empty',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noTitle), findsOneWidget);
    });

    // タイトル入力時の確認ダイアログに入力値が表示される
    testWidgets('confirmation dialog shows entered title', (tester) async {
      await pumpPage(tester);

      await tester.enterText(find.byType(TextField), 'テストスポット');
      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('テストスポット'),
        ),
        findsOneWidget,
      );
    });

    // 確認ダイアログのキャンセルでダイアログが閉じる
    testWidgets('canceling confirmation dialog closes dialog', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoConfirmMessage), findsNothing);
    });

    // 確認ダイアログの保存で保存完了ダイアログが表示される
    testWidgets('confirming save shows save complete dialog', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saved), findsOneWidget);
    });

    // 保存完了ダイアログの閉じるでページを離れる
    testWidgets('closing save complete dialog leaves the page', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WantToGoPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.closeButton));
      await tester.pumpAndSettle();

      expect(find.byType(WantToGoPage), findsNothing);
    });
  });
}
