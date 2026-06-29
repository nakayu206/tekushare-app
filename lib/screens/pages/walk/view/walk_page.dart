import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/spot/view/want_to_go_page.dart';
import 'package:tekushare/screens/pages/walk/view/end_walk_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/clock_header.dart';
import 'package:tekushare/screens/widgets/common/primary_button.dart';

/// 散歩モード画面
class WalkPage extends ConsumerWidget {
  const WalkPage({super.key});

  Future<void> _onTakePhotoPressed(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Position> locationState,
  ) async {
    if (!locationState.hasValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.gpsUnavailableError)),
      );
      return;
    }

    final imagePath = await ref.read(cameraServiceProvider).takePhoto();
    if (imagePath == null || !context.mounted) return;

    ref.read(pendingPhotoProvider.notifier).state = imagePath;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.photoTaken)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ClockHeader(),
            const SizedBox(height: 16),
            _GpsStatusIndicator(locationState: locationState),
            const Spacer(flex: 2),
            Center(
              child: _WalkActionButton(
                label: AppStrings.takePhoto,
                svgAsset: 'assets/SVG/camera.svg',
                fontSize: AppTextStyle.x1l,
                onPressed: () =>
                    _onTakePhotoPressed(context, ref, locationState),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: _WalkActionButton(
                label: AppStrings.saveToWantToGo,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WantToGoPage()),
                ),
              ),
            ),
            const Spacer(flex: 3),
            Center(
              child: PrimaryButton(
                label: AppStrings.endWalk,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EndWalkPage()),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpotListPage()),
            );
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
// GPS 状態インジケーター
// ──────────────────────────────────────────

class _GpsStatusIndicator extends StatelessWidget {
  const _GpsStatusIndicator({required this.locationState});

  final AsyncValue<Position> locationState;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: locationState.when(
          data: (_) => const SizedBox.shrink(),
          loading: () => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8),
              Text(
                AppStrings.gpsAcquiring,
                style: TextStyle(color: AppColors.textDisabled),
              ),
            ],
          ),
          error: (_, __) => const Text(
            AppStrings.gpsUnavailableError,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 散歩アクションボタン（ブラウン）
// ──────────────────────────────────────────

class _WalkActionButton extends StatelessWidget {
  const _WalkActionButton({
    required this.label,
    this.svgAsset,
    this.fontSize = AppTextStyle.xl,
    required this.onPressed,
  });

  final String label;
  final String? svgAsset;
  final double fontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 364,
      height: 105,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(52),
        color: AppColors.textAccent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textAccent,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(52),
          ),
        ),
        child: svgAsset != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: SvgPicture.asset(
                      svgAsset!,
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textOnPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
