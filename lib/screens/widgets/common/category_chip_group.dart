import 'package:flutter/material.dart';

import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';

/// カテゴリ選択チップグループ（3列2行）
class CategoryChipGroup extends StatelessWidget {
  const CategoryChipGroup({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  }) : assert(categories.length == 6,
            'CategoryChipGroup requires exactly 6 categories');

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  Widget _chip(String cat, double height) {
    final isSelected = selectedCategory == cat;
    return GestureDetector(
      onTap: () => onSelected(cat),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.listSelected : AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Center(
          child: Text(
            cat,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: AppTextStyle.sm2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = AppSizingTheme.of(context).chipHeight;
    const gap = SizedBox(width: 8);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _chip(categories[0], h)),
            gap,
            Expanded(child: _chip(categories[1], h)),
            gap,
            Expanded(child: _chip(categories[2], h)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _chip(categories[3], h)),
            gap,
            Expanded(child: _chip(categories[4], h)),
            gap,
            Expanded(child: _chip(categories[5], h)),
          ],
        ),
      ],
    );
  }
}
