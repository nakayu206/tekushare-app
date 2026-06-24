import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/spot/viewmodel/want_to_go_viewmodel.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/category_chip_group.dart';
import 'package:tekushare/screens/widgets/common/dashed_border_painter.dart';

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

  void _onSavePressed() {
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: _titleController.text.isEmpty
            ? AppStrings.noTitle
            : _titleController.text,
        onConfirm: () {
          Navigator.pop(context);
          if (!mounted) return;
          _showSavedDialog();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showSavedDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _SavedDialog(
        onClose: () {
          Navigator.pop(context); // ダイアログを閉じる
          Navigator.pop(context); // 行きたいリストへ戻る
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 34),
              CategoryChipGroup(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: vm.selectCategory,
              ),
              const SizedBox(height: 34),
              _TitleInput(controller: _titleController),
              const SizedBox(height: 34),
              const _PhotoBox(),
              const SizedBox(height: 34),
              _SaveButton(onPressed: _onSavePressed),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SpotListPage()),
              (route) => route.isFirst,
            );
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WalkRoutePage()),
              (route) => route.isFirst,
            );
          } else if (index == 3) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
              (route) => route.isFirst,
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

class _LocationArea extends StatelessWidget {
  const _LocationArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 161,
      decoration: BoxDecoration(
        color: AppColors.chipUnselected,
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
  const _PhotoBox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPath = ref.watch(pendingPhotoProvider);

    if (photoPath != null) {
      return SizedBox(
        width: AppSize.photoBoxWidth,
        height: AppSize.photoBoxHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Image.file(
            File(photoPath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        ),
      );
    }

    return SizedBox(
      width: AppSize.photoBoxWidth,
      height: AppSize.photoBoxHeight,
      child: CustomPaint(
        painter: const DashedBorderPainter(),
        child: _placeholder(),
      ),
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
        const SizedBox(height: AppSpacing.sm),
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
    return SizedBox(
      width: double.infinity,
      height: 94,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(47),
          ),
        ),
        child: const Text(
          AppStrings.wantToGoSave,
          style: TextStyle(
              fontSize: AppTextStyle.lg2, fontWeight: FontWeight.w500),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
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

// ──────────────────────────────────────────
// 保存完了ダイアログ
// ──────────────────────────────────────────

class _SavedDialog extends StatelessWidget {
  const _SavedDialog({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.saved,
              style: TextStyle(
                  fontSize: AppTextStyle.lg2, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
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
