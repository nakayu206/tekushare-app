import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:latlong2/latlong.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/map_constants.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/settings/viewmodel/settings_viewmodel.dart';
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
class WalkPage extends ConsumerStatefulWidget {
  const WalkPage({super.key});

  @override
  ConsumerState<WalkPage> createState() => _WalkPageState();
}

class _WalkPageState extends ConsumerState<WalkPage> {
  final _mapController = MapController();
  final _trackPoints = <LatLng>[];
  final _photoMarkers = <({LatLng point, String imagePath})>[];
  LatLng? _currentPosition;

  Timer? _tickTimer;
  int? _turnSecondsLeft;
  int? _inactSecondsLeft;
  bool _turnFired = false;
  bool _inactFired = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsViewModelProvider);
    if (settings.timerEnabled) {
      final oneWayMinutes = settings.timerRoundTrip
          ? settings.timerMinutes ~/ 2
          : settings.timerMinutes;
      _turnSecondsLeft = oneWayMinutes * 60;
    }
    if (settings.inactivityEnabled) {
      _inactSecondsLeft = settings.inactivityMinutes * 60;
    }
    _tickTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer _) {
    if (!mounted) return;
    setState(() {
      if (_turnSecondsLeft != null && _turnSecondsLeft! > 0) {
        _turnSecondsLeft = _turnSecondsLeft! - 1;
      }
      if (_inactSecondsLeft != null && _inactSecondsLeft! > 0) {
        _inactSecondsLeft = _inactSecondsLeft! - 1;
      }
    });
    _fireNotificationsIfNeeded();
  }

  Future<void> _fireNotificationsIfNeeded() async {
    final svc = ref.read(notificationServiceProvider);
    if (_turnSecondsLeft == 0 && !_turnFired) {
      _turnFired = true;
      await svc.showTurnaroundNotification();
    }
    if (_inactSecondsLeft == 0 && !_inactFired) {
      _inactFired = true;
      await svc.showInactivityNotification();
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _onTakePhotoPressed(
    BuildContext context,
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
    if (_currentPosition != null) {
      setState(() {
        _photoMarkers.add((point: _currentPosition!, imagePath: imagePath));
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.photoTaken)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // エラー時は _GpsStatusIndicator（ref.watch 側）がフィードバックを担う
    ref.listen<AsyncValue<Position>>(locationProvider, (_, next) {
      next.whenData((pos) {
        final point = LatLng(pos.latitude, pos.longitude);
        final isFirstFix = _currentPosition == null;
        final settings = ref.read(settingsViewModelProvider);
        setState(() {
          _currentPosition = point;
          _trackPoints.add(point);
          // GPS 移動で不活動タイマーをリセット
          if (_inactSecondsLeft != null) {
            _inactSecondsLeft = settings.inactivityMinutes * 60;
            _inactFired = false;
          }
        });
        // 初回はマップ未生成のため move() をスキップ
        if (!isFirstFix) {
          _mapController.move(point, _mapController.camera.zoom);
        }
      });
    });

    final locationState = ref.watch(locationProvider);
    final sizing = AppSizingTheme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ClockHeader(),
              const SizedBox(height: AppSpacing.lg),
              _GpsStatusIndicator(locationState: locationState),
              if (_turnSecondsLeft != null || _inactSecondsLeft != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x2l,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_turnSecondsLeft != null) ...[
                        _WalkTimerChip(
                          label: AppStrings.timerTurnaround,
                          icon: Icons.notifications_outlined,
                          seconds: _turnSecondsLeft!,
                        ),
                        if (_inactSecondsLeft != null)
                          const SizedBox(width: AppSpacing.sm),
                      ],
                      if (_inactSecondsLeft != null)
                        _WalkTimerChip(
                          label: AppStrings.timerInactivity,
                          icon: Icons.directions_walk,
                          seconds: _inactSecondsLeft!,
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: _currentPosition != null
                    ? FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition!,
                          initialZoom: MapConstants.defaultZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.tekushare',
                          ),
                          if (_trackPoints.length >= 2)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _trackPoints,
                                  color: AppColors.primary,
                                  strokeWidth: MapConstants.polylineStrokeWidth,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentPosition!,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: AppSize.iconMd,
                                ),
                              ),
                            ],
                          ),
                          if (_photoMarkers.isNotEmpty)
                            MarkerLayer(
                              markers: _photoMarkers
                                  .map(
                                    (m) => Marker(
                                      point: m.point,
                                      width: MapConstants.photoThumbnailSize,
                                      height: MapConstants.photoThumbnailSize,
                                      child: ClipOval(
                                        child: Image.file(
                                          File(m.imagePath),
                                          width:
                                              MapConstants.photoThumbnailSize,
                                          height:
                                              MapConstants.photoThumbnailSize,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const ColoredBox(
                                            color: AppColors.textDisabled,
                                            child: Icon(
                                              Icons.photo,
                                              color: AppColors.textOnPrimary,
                                              size: AppSize.iconSm,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: FloatingActionButton(
                                heroTag: 'recenter',
                                tooltip: AppStrings.recenterMap,
                                onPressed: () {
                                  if (_currentPosition != null) {
                                    _mapController.move(
                                      _currentPosition!,
                                      MapConstants.defaultZoom,
                                    );
                                  }
                                },
                                backgroundColor: AppColors.surface,
                                foregroundColor: AppColors.primary,
                                elevation: 2,
                                child: const Icon(Icons.my_location),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              color: MapConstants.osmAttributionBg,
                              padding: const EdgeInsets.symmetric(
                                horizontal: MapConstants.osmAttributionPaddingH,
                                vertical: MapConstants.osmAttributionPaddingV,
                              ),
                              child: const Text(
                                '© OpenStreetMap contributors',
                                style: TextStyle(
                                  fontSize: MapConstants.osmAttributionFontSize,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x2l,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _WalkActionButton(
                        label: AppStrings.takePhoto,
                        svgAsset: 'assets/SVG/camera.svg',
                        onPressed: () =>
                            _onTakePhotoPressed(context, locationState),
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _WalkActionButton(
                        label: AppStrings.wantToGo,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WantToGoPage(),
                          ),
                        ),
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x2l,
                ),
                child: PrimaryButton(
                  label: AppStrings.endWalk,
                  height: sizing.largeBtnHeight,
                  onPressed: () {
                    ref.read(notificationServiceProvider).cancelAll();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EndWalkPage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
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
    return locationState.when(
      data: (_) => const SizedBox.shrink(),
      loading: () => const SizedBox(
        height: AppSize.gpsIndicatorHeight,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: AppSize.gpsSpinnerSize,
                height: AppSize.gpsSpinnerSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppSize.gpsSpinnerStroke,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.gpsAcquiring,
                style: TextStyle(color: AppColors.textDisabled),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => const SizedBox(
        height: AppSize.gpsIndicatorHeight,
        child: Center(
          child: Text(
            AppStrings.gpsUnavailableError,
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// タイマーチップ
// ──────────────────────────────────────────

class _WalkTimerChip extends StatelessWidget {
  const _WalkTimerChip({
    required this.label,
    required this.icon,
    required this.seconds,
  });

  final String label;
  final IconData icon;
  final int seconds;

  Color _color() {
    if (seconds < 60) return AppColors.error;
    if (seconds < 120) return AppColors.warning;
    return AppColors.primary;
  }

  String _formatted() {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSize.iconXs, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSize.timerChipLabelFontSize,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _formatted(),
            style: TextStyle(
              fontSize: AppSize.timerChipCountFontSize,
              fontWeight: FontWeight.w600,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
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
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final String? svgAsset;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);
    final height = compact ? sizing.detailBtnHeight : sizing.actionBtnHeight;
    final fontSize =
        compact ? sizing.detailBtnFontSize : sizing.actionBtnFontSize;
    final iconSize = compact ? AppSize.iconMd : sizing.actionBtnIconSize;
    final radius = compact ? sizing.detailBtnRadius : sizing.actionBtnRadius;

    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
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
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: svgAsset != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: SvgPicture.asset(
                      svgAsset!,
                      width: iconSize,
                      height: iconSize,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textOnPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
