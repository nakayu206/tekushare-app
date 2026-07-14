import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/map_constants.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/spot/viewmodel/spot_detail_viewmodel.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/app_confirm_dialog.dart';
import 'package:tekushare/screens/widgets/common/category_chip_group.dart';
import 'package:tekushare/screens/widgets/common/dashed_border_painter.dart';
import 'package:tekushare/screens/widgets/common/photo_viewer_dialog.dart';

/// 行きたい！／行った！共通詳細ページ
class SpotDetailPage extends ConsumerStatefulWidget {
  const SpotDetailPage({super.key, required this.spot});

  final Spot spot;

  @override
  ConsumerState<SpotDetailPage> createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends ConsumerState<SpotDetailPage> {
  final _titleController = TextEditingController();
  late List<String> _photoPaths;

  static const _categories = [
    AppStrings.categoryPark,
    AppStrings.categoryCafe,
    AppStrings.categoryLunch,
    AppStrings.categoryDinner,
    AppStrings.categoryGoods,
    AppStrings.categoryOther,
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text =
        widget.spot.title == AppStrings.noTitle ? '' : widget.spot.title;
    _photoPaths = List.of(widget.spot.photoPaths);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(spotDetailViewModelProvider.notifier)
            .initCategory(widget.spot.category);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _onPhotoTap() async {
    final camera = ref.read(cameraServiceProvider);
    final notifier = ref.read(spotProvider.notifier);
    final path = await camera.takePhoto();
    if (path == null || !mounted) return;
    final url = await notifier.attachPhoto(widget.spot.id, path);
    if (!mounted) return;
    setState(() => _photoPaths = [..._photoPaths, url]);
  }

  Future<void> _onPhotoDelete(String path) async {
    if (!mounted) return;
    final notifier = ref.read(spotProvider.notifier);
    await notifier.removePhoto(widget.spot.id, path);
    if (!mounted) return;
    setState(() => _photoPaths = _photoPaths.where((p) => p != path).toList());
  }

  void _onPhotoExpand(String path) {
    showPhotoViewer(context, path, onDelete: () => _onPhotoDelete(path));
  }

  void _onSavePressed() {
    final title = _titleController.text.isEmpty
        ? AppStrings.noTitle
        : _titleController.text;
    final category = ref.read(spotDetailViewModelProvider).selectedCategory;
    final notifier = ref.read(spotProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: AppStrings.spotDetailSaveConfirmMessage,
        confirmLabel: AppStrings.saveButton,
        onConfirm: () => _runWithLoading(
          () => notifier.updateSpot(
            widget.spot.copyWith(title: title, category: category),
          ),
          AppStrings.saved,
        ),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _onDeletePressed() {
    final notifier = ref.read(spotProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: _titleController.text.isEmpty
            ? AppStrings.noTitle
            : _titleController.text,
        message: AppStrings.spotDetailDeleteConfirmMessage,
        confirmLabel: AppStrings.spotDetailDeleteButton,
        isDestructive: true,
        onConfirm: () => _runWithLoading(
          () => notifier.deleteSpot(widget.spot.id),
          AppStrings.spotDetailDeleted,
        ),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _onMoveToWentPressed() {
    final title = _titleController.text.isEmpty
        ? AppStrings.noTitle
        : _titleController.text;
    final category = ref.read(spotDetailViewModelProvider).selectedCategory;
    final notifier = ref.read(spotProvider.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: AppStrings.spotDetailMoveToWentConfirmMessage,
        confirmLabel: AppStrings.spotDetailMoveToWentButton,
        confirmColor: AppColors.listSelected,
        onConfirm: () => _runWithLoading(
          () => notifier.updateSpot(
            widget.spot.copyWith(
              title: title,
              status: SpotStatus.visited,
              category: category,
            ),
          ),
          AppStrings.spotDetailMoveToWentDone,
        ),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// 確認ダイアログを閉じ→ローディング表示→操作完了→ページバック+SnackBar
  Future<void> _runWithLoading(
    Future<void> Function() operation,
    String message,
  ) async {
    Navigator.pop(context); // 確認ダイアログを閉じる
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    await operation();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context); // ローディングを閉じる
    Navigator.pop(context); // 詳細ページから戻る
    messenger.showSnackBar(SnackBar(content: Text(message)));
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
          widget.spot.status == SpotStatus.wantToGo
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
              _LocationArea(
                latitude: widget.spot.latitude,
                longitude: widget.spot.longitude,
                photoPaths: _photoPaths,
                onPhotoExpand: _onPhotoExpand,
              ),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              CategoryChipGroup(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: vm.selectCategory,
              ),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              _TitleInput(controller: _titleController),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              _PhotoBox(
                photoPaths: _photoPaths,
                onTap: _onPhotoTap,
                onDelete: _onPhotoDelete,
                onExpand: _onPhotoExpand,
              ),
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
              _DeleteButton(onPressed: _onDeletePressed),
              const SizedBox(height: 12),
              _SaveButton(onPressed: _onSavePressed),
              if (widget.spot.status == SpotStatus.wantToGo) ...[
                const SizedBox(height: 12),
                _MoveToWentButton(onPressed: _onMoveToWentPressed),
              ],
              SizedBox(height: AppSizingTheme.of(context).sectionSpacing),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
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

class _LocationArea extends StatelessWidget {
  const _LocationArea({
    required this.latitude,
    required this.longitude,
    required this.photoPaths,
    this.onPhotoExpand,
  });

  final double latitude;
  final double longitude;
  final List<String> photoPaths;
  final void Function(String path)? onPhotoExpand;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    final height = AppSizingTheme.of(context).locationAreaHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: MapConstants.defaultZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
            onTap: (_, __) async {
              final uri = Uri.parse(
                'https://www.google.com/maps/dir/?api=1'
                '&destination=$latitude,$longitude',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.tekushare',
            ),
            MarkerLayer(
              markers: [
                if (photoPaths.isEmpty)
                  Marker(
                    point: point,
                    width: AppSize.iconLg,
                    height: AppSize.iconLg,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: AppSize.iconLg,
                    ),
                  ),
                for (final path in photoPaths)
                  Marker(
                    point: point,
                    width: MapConstants.photoThumbnailSize,
                    height: MapConstants.photoThumbnailSize,
                    child: GestureDetector(
                      onTap: () => onPhotoExpand?.call(path),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: path,
                          width: MapConstants.photoThumbnailSize,
                          height: MapConstants.photoThumbnailSize,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const ColoredBox(
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
          color: AppColors.textDisabled,
          fontSize: AppTextStyle.x2l,
        ),
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

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.photoPaths,
    required this.onTap,
    required this.onDelete,
    required this.onExpand,
  });

  final List<String> photoPaths;
  final VoidCallback onTap;
  final void Function(String) onDelete;
  final void Function(String) onExpand;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);
    final screenW = MediaQuery.sizeOf(context).width;
    final tileW = (screenW - 32 - AppSpacing.md) / 2;
    final tileH = sizing.photoBoxHeight;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final path in photoPaths)
          Stack(
            children: [
              GestureDetector(
                onTap: () => onExpand(path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CachedNetworkImage(
                    imageUrl: path,
                    width: tileW,
                    height: tileH,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(sizing),
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
              child: _placeholder(sizing),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(AppSizingTheme sizing) {
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
