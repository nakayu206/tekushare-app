import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/spot/viewmodel/spot_detail_viewmodel.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
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

  void _onMoveToWentPressed() {
    showDialog<void>(
      context: context,
      builder: (_) => _MoveToWentConfirmDialog(
        title: _titleController.text.isEmpty
            ? AppStrings.noTitle
            : _titleController.text,
        onConfirm: () {
          Navigator.pop(context);
          if (!mounted) return;
          _showResultDialog(AppStrings.spotDetailMoveToWentDone);
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
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              CategoryChipGroup(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: vm.selectCategory,
              ),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              _TitleInput(controller: _titleController),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              const _PhotoBox(),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              if (widget.isWantToGo)
                _MoveToWentButton(onPressed: _onMoveToWentPressed)
              else
                _DeleteButton(onPressed: _onDeletePressed),
              const SizedBox(height: 16),
              _SaveButton(onPressed: _onSavePressed),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
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
      height: AppSizingTheme.of(context).locationAreaHeight,
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

class _PhotoBox extends StatelessWidget {
  const _PhotoBox();

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);
    return SizedBox(
      width: sizing.photoBoxWidth,
      height: sizing.photoBoxHeight,
      child: CustomPaint(
        painter: const DashedBorderPainter(),
        child: Column(
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
    final sizing = AppSizingTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: sizing.detailBtnHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizing.detailBtnRadius),
          ),
        ),
        child: Text(
          AppStrings.spotDetailDeleteButton,
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
// 行った！に保存ボタン
// ──────────────────────────────────────────

class _MoveToWentButton extends StatelessWidget {
  const _MoveToWentButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: sizing.detailBtnHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.listSelected,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizing.detailBtnRadius),
          ),
        ),
        child: Text(
          AppStrings.spotDetailMoveToWentButton,
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
// 上書き保存ボタン
// ──────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: sizing.detailBtnHeight,
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
          AppStrings.spotDetailSaveButton,
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
                color: AppColors.primary,
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
                    child: const Text(AppStrings.spotDetailDeleteButton),
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
// 行った！に保存確認ダイアログ
// ──────────────────────────────────────────

class _MoveToWentConfirmDialog extends StatelessWidget {
  const _MoveToWentConfirmDialog({
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
        horizontal: AppSpacing.x2l,
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
              AppStrings.spotDetailMoveToWentConfirmMessage,
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
                      backgroundColor: AppColors.listSelected,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(AppStrings.spotDetailMoveToWentButton),
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
              height: AppSizingTheme.of(context).dialogBtnHeight,
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
