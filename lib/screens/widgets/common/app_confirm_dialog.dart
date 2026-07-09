import 'package:flutter/material.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';

/// キャンセル＋確認ボタンを持つ汎用ダイアログ。
///
/// - [title] を渡すと本文上部に primary 色の見出しを表示する。
/// - [isDestructive] が true のとき確認ボタンを赤色にする。
/// - [confirmColor] を渡すと [isDestructive] より優先してその色を使う。
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.title,
    this.isDestructive = false,
    this.confirmColor,
  });

  final String? title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;
  final Color? confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  Color get _confirmColor {
    if (confirmColor != null) return confirmColor!;
    return isDestructive ? Colors.red.shade400 : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x2l,
          AppSpacing.x3l,
          AppSpacing.x2l,
          AppSpacing.x2l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppTextStyle.lg2,
                  fontWeight: AppTextStyle.semiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: AppTextStyle.md),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSpacing.x5l,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Text(AppStrings.cancelButton),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SizedBox(
                    height: AppSpacing.x5l,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        backgroundColor: _confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
