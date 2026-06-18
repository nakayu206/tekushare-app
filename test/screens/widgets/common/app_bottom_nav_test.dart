import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  group('AppBottomNav', () {
    // 選択インデックスが正しく設定される
    testWidgets('sets selected index correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(currentIndex: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 2);
    });

    // タップ時に onTap が呼ばれる
    testWidgets('calls onTap when tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('リスト'));
      expect(tappedIndex, 1);
    });
  });
}
