import 'package:flutter/material.dart';

import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';

/// アプリ共通のプライマリボタン
/// 幅は親ウィジェットに従う（呼び出し側で Padding などで余白を指定）。
/// 高さ・フォントサイズ・角丸は AppSizingTheme から取得する。
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
  });

  final String label;
  final VoidCallback onPressed;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);

    return Container(
      width: double.infinity,
      height: height ?? sizing.primaryBtnHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(sizing.primaryBtnRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizing.primaryBtnRadius),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: sizing.primaryBtnFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
