import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/core/constants/map_constants.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:url_launcher/url_launcher.dart';

/// 連携アカウントのスポット詳細（読み取り専用）
class LinkedSpotDetailPage extends StatelessWidget {
  const LinkedSpotDetailPage({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);
    final point = LatLng(spot.latitude, spot.longitude);
    final isWantToGo = spot.status == SpotStatus.wantToGo;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
            isWantToGo ? AppStrings.wantToGoPageTitle : AppStrings.listWentTab),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.x4l,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MapArea(
                  point: point,
                  latitude: spot.latitude,
                  longitude: spot.longitude,
                  height: sizing.locationAreaHeight * 1.4),
              SizedBox(height: sizing.sectionSpacing),
              const _SectionLabel(label: AppStrings.linkedSpotLabelTitle),
              const SizedBox(height: AppSpacing.xs),
              _TitleText(title: spot.title),
              if (spot.category != null && spot.category!.isNotEmpty) ...[
                SizedBox(height: sizing.sectionSpacing),
                const _SectionLabel(label: AppStrings.linkedSpotLabelTag),
                const SizedBox(height: AppSpacing.xs),
                _CategoryChip(category: spot.category!),
              ],
              if (spot.photoPaths.isNotEmpty) ...[
                SizedBox(height: sizing.sectionSpacing),
                const _SectionLabel(label: AppStrings.linkedSpotLabelPhoto),
                const SizedBox(height: AppSpacing.xs),
                _PhotoGrid(photoPaths: spot.photoPaths),
              ],
              SizedBox(height: sizing.sectionSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapArea extends StatelessWidget {
  const _MapArea({
    required this.point,
    required this.latitude,
    required this.longitude,
    required this.height,
  });

  final LatLng point;
  final double latitude;
  final double longitude;
  final double height;

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: AppTextStyle.sm,
        fontWeight: AppTextStyle.semiBold,
        color: AppColors.textDisabled,
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title == AppStrings.noTitle ? '' : title,
      style: const TextStyle(
        fontSize: AppTextStyle.lg2,
        fontWeight: AppTextStyle.semiBold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: AppTextStyle.sm,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photoPaths});

  final List<String> photoPaths;

  @override
  Widget build(BuildContext context) {
    final tileSize =
        (MediaQuery.sizeOf(context).width - AppSpacing.lg * 2 - AppSpacing.sm) /
            2;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final path in photoPaths)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: tileSize,
              height: tileSize,
              child: Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: AppColors.chipUnselected,
                  child: Icon(Icons.photo, color: AppColors.textDisabled),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
