import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_detail_page.dart';
import 'package:tekushare/screens/pages/spot/viewmodel/spot_list_viewmodel.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/category_chip_group.dart';

/// リストページ（行きたい！／行った！タブ付き）
class SpotListPage extends ConsumerWidget {
  const SpotListPage({super.key});

  static const _categories = [
    AppStrings.categoryPark,
    AppStrings.categoryCafe,
    AppStrings.categoryLunch,
    AppStrings.categoryDinner,
    AppStrings.categoryGoods,
    AppStrings.categoryOther,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spotListViewModelProvider);
    final vm = ref.read(spotListViewModelProvider.notifier);

    final filtered = ref.watch(filteredSpotsProvider);

    final sizing = AppSizingTheme.of(context);

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
            SizedBox(height: sizing.sectionSpacing),
            _TabRow(
              isWantToGo: state.isWantToGoTab,
              onTap: vm.selectTab,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CategoryChipGroup(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: vm.selectCategory,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        AppStrings.spotListEmpty,
                        style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: AppTextStyle.md2,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final spot = filtered[i];
                        return _ListItem(
                          date:
                              '${spot.createdAt.month.toString().padLeft(2, '0')}/${spot.createdAt.day.toString().padLeft(2, '0')}',
                          title: spot.title,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpotDetailPage(spot: spot),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WalkRoutePage()),
              (route) => route.isFirst,
            );
          } else if (index == 3) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
              (route) => route.isFirst,
            );
          }
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: isWantToGo ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
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
    final sizing = AppSizingTheme.of(context);
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
                fontSize: sizing.tabLabelFontSize,
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
        child: Builder(
          builder: (context) {
            final sizing = AppSizingTheme.of(context);
            return Row(
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: sizing.listItemFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: sizing.listItemFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
