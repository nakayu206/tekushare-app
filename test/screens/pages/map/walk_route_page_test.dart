import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  group('WalkRoutePage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: WalkRoutePage()),
        ),
      );
      await tester.pump();
    }

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
        const ProviderScope(
          child: MaterialApp(
            home: WalkRoutePage(showSaveDialogOnLoad: true),
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
        const ProviderScope(
          child: MaterialApp(
            home: WalkRoutePage(showSaveDialogOnLoad: true),
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
        const ProviderScope(
          child: MaterialApp(
            home: WalkRoutePage(showSaveDialogOnLoad: true),
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
        const ProviderScope(
          child: MaterialApp(
            home: WalkRoutePage(showSaveDialogOnLoad: true),
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
  });
}
