import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_defaults.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/presentation/providers/clock_provider.dart';

/// 時刻・片道設定を表示する共通ヘッダー
class ClockHeader extends ConsumerWidget {
  const ClockHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final minutes = AppDefaults.timerMinutes.toString().padLeft(2, '0');

    // 99px はスクリーン最上端からの距離のため SafeArea 分を差し引く
    final topPadding =
        (49 - MediaQuery.of(context).padding.top).clamp(0.0, double.infinity);

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$h:$m',
            style: AppTextStyle.timerDisplay.copyWith(
              color: AppColors.primary,
              fontSize: AppTextStyle.clock,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '片道  00:$minutes',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.primary,
              fontSize: AppTextStyle.x3l,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
