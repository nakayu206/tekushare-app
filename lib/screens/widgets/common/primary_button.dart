import 'package:flutter/material.dart';

import 'package:tekushare/core/constants/app_colors.dart';

// ボタンの寸法・スタイル定数
// デザイン基準値（390dp 幅のデバイスで使用した値）
const _kDesignWidth = 390.0;
const _kHeightRatio = 120.0 / _kDesignWidth; // ≈ 0.308
const _kFontRatio = 28.0 / _kDesignWidth; // ≈ 0.072
const _kBorderRadiusRatio = 60.0 / _kDesignWidth;
const _kShadowOpacity = 0.25;
const _kShadowOffsetY = 4.0;
const _kShadowBlur = 4.0;

/// アプリ共通のプライマリボタン
/// 幅は親ウィジェットに従う（呼び出し側で Padding などで余白を指定）。
/// 高さ・フォントサイズは画面幅に比例してスケーリングされる。
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final height = (sw * _kHeightRatio).clamp(72.0, 120.0);
    final fontSize = (sw * _kFontRatio).clamp(18.0, 28.0);
    final radius = (sw * _kBorderRadiusRatio).clamp(36.0, 60.0);

    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _kShadowOpacity),
            offset: const Offset(0, _kShadowOffsetY),
            blurRadius: _kShadowBlur,
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
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
