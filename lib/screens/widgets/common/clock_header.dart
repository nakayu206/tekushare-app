import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/pages/settings/viewmodel/settings_viewmodel.dart';
import 'package:tekushare/screens/providers/clock_provider.dart';

/// 時刻・片道設定を表示する共通ヘッダー
class ClockHeader extends ConsumerWidget {
  const ClockHeader({super.key, this.countdownSeconds});

  /// 指定するとリアルタイムカウントダウン（MM:SS）を表示する
  final int? countdownSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');

    final settings = ref.watch(settingsViewModelProvider);
    final label = settings.timerRoundTrip ? '往復' : '片道';

    final String timeLabel;
    if (countdownSeconds != null) {
      final mm = (countdownSeconds! ~/ 60).toString().padLeft(2, '0');
      final ss = (countdownSeconds! % 60).toString().padLeft(2, '0');
      timeLabel = '$label  $mm:$ss';
    } else {
      final mm = settings.timerMinutes.toString().padLeft(2, '0');
      timeLabel = '$label  $mm:00';
    }

    // 99px はスクリーン最上端からの距離のため SafeArea 分を差し引く
    final topPadding =
        (49 - MediaQuery.of(context).padding.top).clamp(0.0, double.infinity);

    final sizing = AppSizingTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$h:$m',
            style: AppTextStyle.timerDisplay.copyWith(
              color: AppColors.primary,
              fontSize: sizing.clockFontSize,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            timeLabel,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.primary,
              fontSize: sizing.clockLabelFontSize,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
