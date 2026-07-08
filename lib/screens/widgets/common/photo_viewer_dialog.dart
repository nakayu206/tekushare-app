import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/core/constants/map_constants.dart';

/// 写真をフルスクリーンで表示し、削除も行えるビューアーを開く
void showPhotoViewer(
  BuildContext context,
  String path,
  void Function() onDelete,
) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: SizedBox.expand(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: AppSize.iconXl,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.lg,
              right: AppSpacing.lg,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: AppSize.mapPinSize,
                  height: AppSize.mapPinSize,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: MapConstants.photoViewerCloseIconSize,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: AppSpacing.x2l,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onDelete();
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: AppSize.iconMd,
                  ),
                  label: const Text(
                    AppStrings.removePhoto,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTextStyle.md2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
