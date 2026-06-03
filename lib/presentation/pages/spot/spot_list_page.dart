import 'package:flutter/material.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/presentation/pages/spot/spot_detail_page.dart';
import 'package:tekushare/presentation/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/presentation/widgets/common/category_chip_group.dart';

/// リストページ（行きたい！／行った！タブ付き）
class SpotListPage extends StatefulWidget {
  const SpotListPage({super.key});

  @override
  State<SpotListPage> createState() => _SpotListPageState();
}

class _SpotListPageState extends State<SpotListPage> {
  bool _isWantToGoTab = true;
  String _selectedCategory = AppStrings.categoryPark;

  static const _categories = [
    AppStrings.categoryPark,
    AppStrings.categoryCafe,
    AppStrings.categoryLunch,
    AppStrings.categoryDinner,
    AppStrings.categoryGoods,
    AppStrings.categoryOther,
  ];

  static const _wantToGoItems = [
    (date: '4/12', title: 'ひだまりパーク'),
    (date: '5/12', title: 'Cafe&Gallery'),
    (date: '6/12', title: 'カフェ Noce'),
    (date: '7/12', title: 'むすび屋（雑貨屋）'),
    (date: '8/12', title: 'ごはん処 まるふく'),
    (date: '9/12', title: 'cafe hanahana'),
    (date: '10/12', title: 'time spot'),
  ];

  static const _wentItems = [
    (date: '1/15', title: '新宿御苑'),
    (date: '2/03', title: 'タリーズ 銀座店'),
    (date: '3/20', title: 'ブルーボトルコーヒー'),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _isWantToGoTab ? _wantToGoItems : _wentItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.navList),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 34),
            _TabRow(
              isWantToGo: _isWantToGoTab,
              onTap: (v) => setState(() => _isWantToGoTab = v),
            ),
            const SizedBox(height: 32),
            // TODO(#8): カテゴリフィルタリングはデータ連携issueで実装
            CategoryChipGroup(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _ListItem(
                  date: items[i].date,
                  title: items[i].title,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SpotDetailPage(isWantToGo: _isWantToGoTab),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0 && Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// アンダーライン式タブ
// ──────────────────────────────────────────

class _TabRow extends StatelessWidget {
  const _TabRow({required this.isWantToGo, required this.onTap});

  final bool isWantToGo;
  final ValueChanged<bool> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _TabLabel(
              label: AppStrings.wantToGo,
              isSelected: isWantToGo,
              onTap: () => onTap(true),
            ),
            _TabLabel(
              label: AppStrings.listWentTab,
              isSelected: !isWantToGo,
              onTap: () => onTap(false),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 160,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isWantToGo ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: 160,
                  height: 5,
                  decoration: BoxDecoration(
                    color: !isWantToGo ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textDisabled,
                fontSize: AppTextStyle.x2l,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// リストアイテム
// ──────────────────────────────────────────

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.date,
    required this.title,
    required this.onTap,
  });

  final String date;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              date,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppTextStyle.xl,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppTextStyle.xl,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
