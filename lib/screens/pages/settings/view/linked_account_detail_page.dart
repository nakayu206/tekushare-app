import 'package:flutter/material.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/domain/entities/linked_account.dart';

/// 連携アカウント詳細画面
/// そのユーザーが共有している行きたい場所・散歩ルートを表示する。
class LinkedAccountDetailPage extends StatelessWidget {
  const LinkedAccountDetailPage({super.key, required this.account});

  final LinkedAccount account;

  static const _mockSpots = [
    (title: 'お気に入り公園', category: '公園', isWantToGo: true),
    (title: '駅前カフェ', category: 'カフェ', isWantToGo: false),
    (title: '商店街の和食屋', category: 'ランチ', isWantToGo: true),
  ];

  static const _mockRoutes = [
    (name: '駅まわりコース', distance: '1.2km', time: '25分'),
    (name: '公園ぐるりコース', distance: '3.5km', time: '52分'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(account.displayName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _AccountHeader(name: account.displayName),
            const SizedBox(height: AppSpacing.x2lp),
            const _SectionHeader(label: AppStrings.wantToGo),
            const SizedBox(height: AppSpacing.sm),
            if (_mockSpots.isEmpty)
              const _EmptyState(message: AppStrings.linkedAccountSpotsEmpty)
            else
              for (final spot in _mockSpots)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SpotCard(
                    title: spot.title,
                    category: spot.category,
                    isWantToGo: spot.isWantToGo,
                  ),
                ),
            const SizedBox(height: AppSpacing.x2lp),
            const _SectionHeader(label: AppStrings.walkRoutePageTitle),
            const SizedBox(height: AppSpacing.sm),
            if (_mockRoutes.isEmpty)
              const _EmptyState(message: AppStrings.linkedAccountRoutesEmpty)
            else
              for (final route in _mockRoutes)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _RouteCard(
                    name: route.name,
                    distance: route.distance,
                    time: route.time,
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: const TextStyle(
              fontSize: AppTextStyle.xl,
              fontWeight: AppTextStyle.semiBold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          name,
          style: const TextStyle(
            fontSize: AppTextStyle.lg2,
            fontWeight: AppTextStyle.semiBold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: AppTextStyle.md2,
        fontWeight: AppTextStyle.semiBold,
        color: AppColors.primary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: AppTextStyle.sm,
            color: AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({
    required this.title,
    required this.category,
    required this.isWantToGo,
  });

  final String title;
  final String category;
  final bool isWantToGo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.chipUnselected),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: AppSpacing.xs,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTextStyle.md2,
                    fontWeight: AppTextStyle.medium,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: AppTextStyle.sm,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              isWantToGo ? AppStrings.wantToGo : AppStrings.listWentTab,
              style: const TextStyle(
                fontSize: AppTextStyle.xs,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.name,
    required this.distance,
    required this.time,
  });

  final String name;
  final String distance;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.chipUnselected),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: AppSpacing.xs,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.route_outlined,
            color: AppColors.primary,
            size: AppSize.iconMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: AppTextStyle.md2,
                fontWeight: AppTextStyle.medium,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$distance · $time',
            style: const TextStyle(
              fontSize: AppTextStyle.sm,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
