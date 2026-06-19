import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/spot/viewmodel/spot_detail_viewmodel.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/category_chip_group.dart';
import 'package:tekushare/screens/widgets/common/dashed_border_painter.dart';

/// 行きたい！／行った！共通詳細ページ
class SpotDetailPage extends ConsumerStatefulWidget {
  const SpotDetailPage({super.key, required this.isWantToGo});

  final bool isWantToGo;

  @override
  ConsumerState<SpotDetailPage> createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends ConsumerState<SpotDetailPage> {
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
      builder: (_) => _SaveConfirmDialog(
        title: _titleController.text.isEmpty
            ? AppStrings.noTitle
            : _titleController.text,
        onConfirm: () {
          Navigator.pop(context);
          if (!mounted) return;
          _showResultDialog(AppStrings.saved);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _onDeletePressed() {
    showDialog<void>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        title: _titleController.text.isEmpty
            ? AppStrings.noTitle
            : _titleController.text,
        onConfirm: () {
          Navigator.pop(context);
          if (!mounted) return;
          _showResultDialog(AppStrings.spotDetailDeleted);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showResultDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => _ResultDialog(
        message: message,
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spotDetailViewModelProvider);
    final vm = ref.read(spotDetailViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.isWantToGo
              ? AppStrings.wantToGoPageTitle
              : AppStrings.listWentTab,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
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
              const _TwoPhotoRow(),
              const SizedBox(height: 34),
              _DeleteButton(onPressed: _onDeletePressed),
              const SizedBox(height: 16),
              _SaveButton(onPressed: _onSavePressed),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context);
          } else if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalkRoutePage()),
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
          color: AppColors.textDisabled,
          fontSize: AppTextStyle.x2l,
        ),
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
// 写真エリア（2枚横並び）
// ──────────────────────────────────────────

class _TwoPhotoRow extends StatelessWidget {
  const _TwoPhotoRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _PhotoBox()),
        SizedBox(width: 16),
        Expanded(child: _PhotoBox()),
      ],
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: const DashedBorderPainter(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/SVG/camera.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.textAccent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.addPhoto,
              style: TextStyle(
                color: AppColors.textAccent,
                fontSize: AppTextStyle.sm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 削除ボタン
// ──────────────────────────────────────────

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(47),
          ),
        ),
        child: const Text(
          AppStrings.spotDetailDeleteButton,
          style: TextStyle(
            fontSize: AppTextStyle.lg2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 上書き保存ボタン
// ──────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
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
          AppStrings.spotDetailSaveButton,
          style: TextStyle(
            fontSize: AppTextStyle.lg2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 上書き保存確認ダイアログ
// ──────────────────────────────────────────

class _SaveConfirmDialog extends StatelessWidget {
  const _SaveConfirmDialog({
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
              AppStrings.spotDetailSaveConfirmMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
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
                const SizedBox(width: 12),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 削除確認ダイアログ
// ──────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({
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
                fontSize: AppTextStyle.lg2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.spotDetailDeleteConfirmMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
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
                    child: const Text(AppStrings.spotDetailDeleteButton),
                  ),
                ),
                const SizedBox(width: 12),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 完了ダイアログ（保存・削除共通）
// ──────────────────────────────────────────

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({required this.message, required this.onClose});

  final String message;
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
            Text(
              message,
              style: const TextStyle(
                fontSize: AppTextStyle.lg2,
                fontWeight: FontWeight.w500,
              ),
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
