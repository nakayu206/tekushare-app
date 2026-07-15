import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/map_constants.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/spot/viewmodel/want_to_go_viewmodel.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/category_chip_group.dart';
import 'package:tekushare/screens/widgets/common/dashed_border_painter.dart';
import 'package:tekushare/screens/widgets/common/photo_viewer_dialog.dart';

/// 行きたい！ページ
class WantToGoPage extends ConsumerStatefulWidget {
  const WantToGoPage({super.key});

  @override
  ConsumerState<WantToGoPage> createState() => _WantToGoPageState();
}

class _WantToGoPageState extends ConsumerState<WantToGoPage> {
  final _titleController = TextEditingController();

  static const _categories = [
    AppStrings.categoryPark,
    AppStrings.categoryCafe,
    AppStrings.categoryLunch,
    AppStrings.categoryDinner,
    AppStrings.categoryGoods,
    AppStrings.categoryOther,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _onPhotoTap() async {
    final path = await ref.read(cameraServiceProvider).takePhoto();
    if (path == null || !mounted) return;
    ref.read(pendingPhotoProvider.notifier).update((l) => [...l, path]);
  }

  void _onPhotoDelete(String path) {
    ref
        .read(pendingPhotoProvider.notifier)
        .update((l) => l.where((e) => e != path).toList());
  }

  void _onPhotoExpand(String path) {
    showPhotoViewer(context, path, onDelete: () => _onPhotoDelete(path));
  }

  void _onSavePressed() {
    final title = _titleController.text.isEmpty
        ? AppStrings.noTitle
        : _titleController.text;
    final location = ref.read(locationProvider).valueOrNull;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.gpsUnavailableError)),
      );
      return;
    }
    final category = ref.read(wantToGoViewModelProvider).selectedCategory;
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: title,
        onConfirm: () async {
          final notifier = ref.read(spotProvider.notifier);
          Navigator.pop(context); // 確認ダイアログを閉じる
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const PopScope(
              canPop: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
          try {
            final spotId = await notifier.saveSpot(
              title: title,
              latitude: location.latitude,
              longitude: location.longitude,
              category: category,
            );
            final photos = ref.read(pendingPhotoProvider);
            for (final photo in photos) {
              await notifier.attachPhoto(spotId, photo);
            }
            ref.read(pendingPhotoProvider.notifier).state = [];
          } catch (_) {
            if (!mounted) return;
            Navigator.pop(context); // ローディングを閉じる
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.operationError)),
            );
            return;
          }
          if (!mounted) return;
          Navigator.pop(context); // ローディングを閉じる
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => _SavedDialog(
              onClose: () {
                Navigator.pop(context); // ダイアログを閉じる
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          );
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);
    final state = ref.watch(wantToGoViewModelProvider);
    final vm = ref.read(wantToGoViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.wantToGoPageTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _LocationArea(),
              SizedBox(height: sizing.sectionSpacing),
              CategoryChipGroup(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: vm.selectCategory,
              ),
              SizedBox(height: sizing.sectionSpacing),
              _TitleInput(controller: _titleController),
              SizedBox(height: sizing.sectionSpacing),
              _PhotoBox(
                onTap: _onPhotoTap,
                onDelete: _onPhotoDelete,
                onExpand: _onPhotoExpand,
              ),
              SizedBox(height: sizing.sectionSpacing),
              _SaveButton(onPressed: _onSavePressed),
              SizedBox(height: sizing.sectionSpacing),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpotListPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalkRoutePage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          }
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
// リアルタイム位置エリア
// ──────────────────────────────────────────

class _LocationArea extends ConsumerWidget {
  const _LocationArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(locationProvider).valueOrNull;
    final height = AppSizingTheme.of(context).locationAreaHeight;

    if (position == null) {
      return Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Center(
          child: Text(
            AppStrings.realtimeLocation,
            style: TextStyle(
              color: AppColors.textDisabled,
              fontSize: AppTextStyle.md2,
            ),
          ),
        ),
      );
    }

    final photos = ref.watch(pendingPhotoProvider);
    final center = LatLng(position.latitude, position.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: MapConstants.defaultZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.tekushare',
            ),
            MarkerLayer(
              markers: [
                if (photos.isEmpty)
                  Marker(
                    point: center,
                    width: AppSize.iconLg,
                    height: AppSize.iconLg,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: AppSize.iconLg,
                    ),
                  ),
                for (final path in photos)
                  Marker(
                    point: center,
                    width: MapConstants.photoThumbnailSize,
                    height: MapConstants.photoThumbnailSize,
                    child: ClipOval(
                      child: Image.file(
                        File(path),
                        width: MapConstants.photoThumbnailSize,
                        height: MapConstants.photoThumbnailSize,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: AppColors.textDisabled,
                          child: Icon(
                            Icons.photo,
                            color: Colors.white,
                            size: AppSize.iconSm,
                          ),
                        ),
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

// ──────────────────────────────────────────
// タイトル入力
// ──────────────────────────────────────────

class _TitleInput extends StatelessWidget {
  const _TitleInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: AppStrings.titleHint,
        hintStyle: const TextStyle(
            color: AppColors.textDisabled, fontSize: AppTextStyle.x2l),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 写真エリア
// ──────────────────────────────────────────

class _PhotoBox extends ConsumerWidget {
  const _PhotoBox({
    required this.onTap,
    required this.onDelete,
    required this.onExpand,
  });

  final VoidCallback onTap;
  final void Function(String) onDelete;
  final void Function(String) onExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizing = AppSizingTheme.of(context);
    final photos = ref.watch(pendingPhotoProvider);

    final screenW = MediaQuery.sizeOf(context).width;
    final tileW = (screenW - 32 - AppSpacing.md) / 2;
    final tileH = sizing.photoBoxHeight;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final path in photos)
          Stack(
            children: [
              GestureDetector(
                onTap: () => onExpand(path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    width: tileW,
                    height: tileH,
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => onDelete(path),
                  child: Container(
                    width: MapConstants.photoDeleteBadgeSize + 2,
                    height: MapConstants.photoDeleteBadgeSize + 2,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppRadius.sm),
                        bottomLeft: Radius.circular(AppRadius.xs),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: MapConstants.photoDeleteIconSize + 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: tileW,
            height: tileH,
            child: CustomPaint(
              painter: const DashedBorderPainter(),
              child: _placeholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/SVG/camera.svg',
          width: AppSize.iconMd,
          height: AppSize.iconMd,
          colorFilter: const ColorFilter.mode(
            AppColors.textAccent,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          AppStrings.addPhoto,
          style: TextStyle(
            color: AppColors.textAccent,
            fontSize: AppTextStyle.sm,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 保存ボタン
// ──────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: sizing.largeBtnHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizing.detailBtnRadius),
          ),
        ),
        child: Text(
          AppStrings.wantToGoSave,
          style: TextStyle(
            fontSize: sizing.detailBtnFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 保存完了ダイアログ
// ──────────────────────────────────────────

class _SavedDialog extends StatelessWidget {
  const _SavedDialog({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4l,
        vertical: AppSpacing.x2l,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          28,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.saved,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppTextStyle.lg2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(AppStrings.closeButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 確認ダイアログ
// ──────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4l,
        vertical: AppSpacing.x2l,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          28,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppTextStyle.lg2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.wantToGoConfirmMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(AppStrings.cancelButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(AppStrings.saveButton),
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
