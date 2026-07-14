import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/domain/entities/linked_account.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/screens/pages/settings/view/linked_spot_detail_page.dart';
import 'package:tekushare/screens/providers/linked_account_spots_provider.dart';

/// 連携アカウント詳細画面
/// そのユーザーが共有している行きたい場所・散歩ルートを表示する。
class LinkedAccountDetailPage extends ConsumerWidget {
  const LinkedAccountDetailPage({super.key, required this.account});

  final LinkedAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotsAsync = ref.watch(linkedAccountSpotsProvider(account.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(account.displayName),
        centerTitle: true,
        elevation: 0,
      ),
      body: spotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text(
            AppStrings.linkedAccountLoadError,
            style: TextStyle(color: AppColors.textDisabled),
          ),
        ),
        data: (spots) => SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const _SectionHeader(label: AppStrings.wantToGo),
              const SizedBox(height: AppSpacing.sm),
              if (spots.wantToGoSpots.isEmpty)
                const _EmptyState(message: AppStrings.linkedAccountSpotsEmpty)
              else
                for (final spot in spots.wantToGoSpots)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _SpotCard(spot: spot, otherUid: account.uid),
                  ),
              const SizedBox(height: AppSpacing.x2lp),
              const _SectionHeader(label: AppStrings.listWentTab),
              const SizedBox(height: AppSpacing.sm),
              if (spots.visitedSpots.isEmpty)
                const _EmptyState(message: AppStrings.linkedAccountSpotsEmpty)
              else
                for (final spot in spots.visitedSpots)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _SpotCard(spot: spot, otherUid: account.uid),
                  ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
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
  const _SpotCard({required this.spot, required this.otherUid});

  final Spot spot;
  final String otherUid;

  @override
  Widget build(BuildContext context) {
    final isWantToGo = spot.status == SpotStatus.wantToGo;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LinkedSpotDetailPage(spot: spot, otherUid: otherUid),
        ),
      ),
      child: Container(
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
                    spot.title,
                    style: const TextStyle(
                      fontSize: AppTextStyle.md2,
                      fontWeight: AppTextStyle.medium,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (spot.category != null && spot.category!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      spot.category!,
                      style: const TextStyle(
                        fontSize: AppTextStyle.sm,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
      ),
    );
  }
}
