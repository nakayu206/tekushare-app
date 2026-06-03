import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/presentation/widgets/common/category_chip_group.dart';

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
    testWidgets('6つのカテゴリが表示される', (tester) async {
      await pumpWidget(tester);

      for (final cat in categories) {
        expect(find.text(cat), findsOneWidget);
      }
    });

    testWidgets('選択中のカテゴリをタップするとonSelectedが呼ばれる', (tester) async {
      String? tapped;
      await pumpWidget(tester, onSelected: (cat) => tapped = cat);

      await tester.tap(find.text(AppStrings.categoryCafe));
      expect(tapped, AppStrings.categoryCafe);
    });

    testWidgets('selectedCategory が変わると表示に反映される', (tester) async {
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
