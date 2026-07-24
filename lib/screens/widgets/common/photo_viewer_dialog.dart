import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/core/constants/map_constants.dart';

/// 写真をフルスクリーンで表示するビューアーを開く。
/// [onDelete] を渡すと削除ボタンを表示する。
Widget _buildImage(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: path,
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(color: Colors.white54)),
      errorWidget: (_, __, ___) => const Icon(
        Icons.broken_image,
        color: Colors.white54,
        size: AppSize.iconXl,
      ),
    );
  }
  return Image.file(
    File(path),
    fit: BoxFit.contain,
    errorBuilder: (_, __, ___) => const Icon(
      Icons.broken_image,
      color: Colors.white54,
      size: AppSize.iconXl,
    ),
  );
}

void showPhotoViewer(
  BuildContext context,
  String path, {
  void Function()? onDelete,
}) {
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
                    child: _buildImage(path),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.lg,
              right: AppSpacing.lg,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: SizedBox(
                  width: MapConstants.photoViewerCloseTapSize,
                  height: MapConstants.photoViewerCloseTapSize,
                  child: Center(
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
              ),
            ),
            if (onDelete != null)
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
