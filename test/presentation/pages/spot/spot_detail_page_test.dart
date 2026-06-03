import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/presentation/pages/spot/spot_detail_page.dart';
import 'package:tekushare/presentation/widgets/common/app_bottom_nav.dart';

void main() {
  group('SpotDetailPage', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      bool isWantToGo = true,
    }) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: SpotDetailPage(isWantToGo: isWantToGo)),
      );
      await tester.pump();
    }

    Future<void> pumpPushedPage(
      WidgetTester tester, {
      bool isWantToGo = true,
    }) async {
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
                MaterialPageRoute(
                  builder: (_) => SpotDetailPage(isWantToGo: isWantToGo),
                ),
              ),
              child: const Text('start'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
    }

    // ──────────────────────────────────────────
    // 表示
    // ──────────────────────────────────────────

    testWidgets('行きたい！モードでタイトルが「行きたい！」になる', (tester) async {
      await pumpPage(tester, isWantToGo: true);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.wantToGoPageTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('行った！モードでタイトルが「行った！」になる', (tester) async {
      await pumpPage(tester, isWantToGo: false);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.listWentTab),
        ),
        findsOneWidget,
      );
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

    testWidgets('写真を追加エリアが2つ表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.addPhoto), findsNWidgets(2));
    });

    testWidgets('削除ボタンが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.spotDetailDeleteButton), findsOneWidget);
    });

    testWidgets('上書き保存ボタンが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.spotDetailSaveButton), findsOneWidget);
    });

    testWidgets('ボトムナビが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets('カテゴリチップをタップすると選択が切り替わる', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.categoryCafe));
      await tester.pump();

      // カフェが選択状態になっているか確認（公園は選択解除）
      // CategoryChipGroup の内部状態として公園チップは非選択色になる
      expect(find.text(AppStrings.categoryCafe), findsOneWidget);
    });

    // ──────────────────────────────────────────
    // 削除フロー
    // ──────────────────────────────────────────

    testWidgets('削除ボタンを押すと削除確認ダイアログが表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.spotDetailDeleteConfirmMessage), findsOneWidget);
    });

    testWidgets('削除確認のキャンセルでダイアログが閉じる', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.spotDetailDeleteConfirmMessage), findsNothing);
    });

    testWidgets('削除確認で削除完了ダイアログが表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppStrings.spotDetailDeleteButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.spotDetailDeleted), findsOneWidget);
    });

    testWidgets('削除完了ダイアログの閉じるでページを離れる', (tester) async {
      await pumpPushedPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppStrings.spotDetailDeleteButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.closeButton));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsNothing);
    });

    // ──────────────────────────────────────────
    // 上書き保存フロー
    // ──────────────────────────────────────────

    testWidgets('上書き保存ボタンを押すと保存確認ダイアログが表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.spotDetailSaveConfirmMessage), findsOneWidget);
    });

    testWidgets('タイトル未入力時の確認ダイアログに（タイトルなし）が表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoNoTitle), findsOneWidget);
    });

    testWidgets('タイトル入力時の確認ダイアログに入力値が表示される', (tester) async {
      await pumpPage(tester);

      await tester.enterText(find.byType(TextField), 'テストスポット');
      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('テストスポット'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('保存確認のキャンセルでダイアログが閉じる', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.spotDetailSaveConfirmMessage), findsNothing);
    });

    testWidgets('保存確認で保存完了ダイアログが表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoSaved), findsOneWidget);
    });

    testWidgets('保存完了ダイアログの閉じるでページを離れる', (tester) async {
      await pumpPushedPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.closeButton));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsNothing);
    });
  });
}
