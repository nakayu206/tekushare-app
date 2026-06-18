import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/widgets/common/category_chip_group.dart';

void main() {
  const categories = [
    AppStrings.categoryPark,
    AppStrings.categoryCafe,
    AppStrings.categoryLunch,
    AppStrings.categoryDinner,
    AppStrings.categoryGoods,
    AppStrings.categoryOther,
  ];

  Future<void> pumpWidget(
    WidgetTester tester, {
    String selected = AppStrings.categoryPark,
    ValueChanged<String>? onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChipGroup(
            categories: categories,
            selectedCategory: selected,
            onSelected: onSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('CategoryChipGroup', () {
    // 6つのカテゴリが表示される
    testWidgets('shows six categories', (tester) async {
      await pumpWidget(tester);

      for (final cat in categories) {
        expect(find.text(cat), findsOneWidget);
      }
    });

    // 選択中のカテゴリをタップするとonSelectedが呼ばれる
    testWidgets('calls onSelected when a category chip is tapped',
        (tester) async {
      String? tapped;
      await pumpWidget(tester, onSelected: (cat) => tapped = cat);

      await tester.tap(find.text(AppStrings.categoryCafe));
      expect(tapped, AppStrings.categoryCafe);
    });

    // selectedCategory が変わると表示に反映される
    testWidgets('reflects selectedCategory change in display', (tester) async {
      String selected = AppStrings.categoryPark;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: CategoryChipGroup(
                categories: categories,
                selectedCategory: selected,
                onSelected: (cat) => setState(() => selected = cat),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.categoryDinner));
      await tester.pump();

      expect(selected, AppStrings.categoryDinner);
    });
  });
}
