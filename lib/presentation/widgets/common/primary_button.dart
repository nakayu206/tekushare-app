import 'package:flutter/material.dart';

import 'package:tekushare/core/constants/app_colors.dart';

// ボタンの寸法・スタイル定数
const _kWidth = 362.0;
const _kHeight = 120.0;
const _kBorderRadius = 60.0;
const _kFontSize = 28.0;
const _kShadowOpacity = 0.25;
const _kShadowOffsetY = 4.0;
const _kShadowBlur = 4.0;

/// アプリ共通のプライマリボタン
/// [label] に表示テキスト、[onPressed] にタップ時のコールバックを渡す
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
    return Container(
      width: _kWidth,
      height: _kHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kBorderRadius),
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
            borderRadius: BorderRadius.circular(_kBorderRadius),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: _kFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
