import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';

/// アプリ共通のボトムナビゲーションバー（Material 3 NavigationBar）
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  // ExcludeSemantics: NavigationDestination の label がセマンティクスを担うため
  // SVG 自体はスクリーンリーダーから除外する
  static Widget _icon(String path, {bool active = false}) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        path,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          active ? Colors.white : AppColors.navInactive,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          // 選択インジケーターは非表示
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.navInactive;
            return TextStyle(fontSize: 11, color: color);
          }),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        height: 90,
        destinations: [
          NavigationDestination(
            icon: _icon('assets/SVG/home.svg'),
            selectedIcon: _icon('assets/SVG/home.svg', active: true),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: _icon('assets/SVG/list.svg'),
            selectedIcon: _icon('assets/SVG/list.svg', active: true),
            label: AppStrings.navList,
          ),
          NavigationDestination(
            icon: _icon('assets/SVG/root.svg'),
            selectedIcon: _icon('assets/SVG/root.svg', active: true),
            label: AppStrings.navRoute,
          ),
          NavigationDestination(
            icon: _icon('assets/SVG/setting.svg'),
            selectedIcon: _icon('assets/SVG/setting.svg', active: true),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
