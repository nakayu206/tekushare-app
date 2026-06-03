import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/presentation/pages/spot/want_to_go_page.dart';
import 'package:tekushare/presentation/widgets/common/app_bottom_nav.dart';

void main() {
  group('WantToGoPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: WantToGoPage()),
      );
      await tester.pump();
    }

    testWidgets('ページタイトルが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGoPageTitle), findsOneWidget);
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

    testWidgets('写真を追加ボタンが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.addPhoto), findsOneWidget);
    });

    testWidgets('保存ボタンが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGoSave), findsOneWidget);
    });

    testWidgets('ボトムナビが表示される', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets('保存ボタンを押すと確認ダイアログが表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoConfirmMessage), findsOneWidget);
    });

    testWidgets('タイトル未入力時の確認ダイアログに（タイトルなし）が表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noTitle), findsOneWidget);
    });

    testWidgets('タイトル入力時の確認ダイアログに入力値が表示される', (tester) async {
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

    testWidgets('確認ダイアログのキャンセルでダイアログが閉じる', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoConfirmMessage), findsNothing);
    });

    testWidgets('確認ダイアログの保存で保存完了ダイアログが表示される', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saved), findsOneWidget);
    });

    testWidgets('保存完了ダイアログの閉じるでページを離れる', (tester) async {
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
                MaterialPageRoute(builder: (_) => const WantToGoPage()),
              ),
              child: const Text('start'),
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
