import 'package:flutter/material.dart';

import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_text_style.dart';

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

  Widget _chip(String cat) {
    final isSelected = selectedCategory == cat;
    return GestureDetector(
      onTap: () => onSelected(cat),
      child: Container(
        width: 108,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.listSelected : AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(48),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip(categories[0]),
            const SizedBox(width: 16),
            _chip(categories[1]),
            const SizedBox(width: 16),
            _chip(categories[2]),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip(categories[3]),
            const SizedBox(width: 16),
            _chip(categories[4]),
            const SizedBox(width: 16),
            _chip(categories[5]),
          ],
        ),
      ],
    );
  }
}
