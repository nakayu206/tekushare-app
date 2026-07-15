import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/providers/walk_history_provider.dart';
import 'package:tekushare/screens/providers/walk_routes_provider.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';
import 'package:tekushare/screens/providers/walk_timer_provider.dart';
import 'package:tekushare/screens/providers/walk_track_points_provider.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/clock_header.dart';

/// 散歩終了確認ページ
class EndWalkPage extends ConsumerStatefulWidget {
  const EndWalkPage({super.key});

  @override
  ConsumerState<EndWalkPage> createState() => _EndWalkPageState();
}

class _EndWalkPageState extends ConsumerState<EndWalkPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _footprintFades;
  late Animation<double> _cardFade;
  bool _isProcessing = false;

  // 画面幅・高さに対する比率で指定（端末サイズ非依存）
  // 左右交互に配置して歩いている感じを表現
  static const _steps = [
    (leftRatio: -0.038, topRatio: 0.264, angle: 0.1), // 左足
    (leftRatio: 0.128, topRatio: 0.292, angle: -0.4), // 右足
    (leftRatio: 0.192, topRatio: 0.372, angle: 0.1), // 左足
    (leftRatio: 0.359, topRatio: 0.400, angle: -0.4), // 右足
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    const footprintEnd = 0.857;
    final count = _steps.length;
    _footprintFades = List.generate(count, (i) {
      final start = (i / count) * footprintEnd;
      final end = ((i + 1) / count) * footprintEnd;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _cardFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(footprintEnd, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_isProcessing) return;
    _isProcessing = true;
    final session = ref.read(walkSessionProvider);
    final trackPoints = ref.read(walkTrackPointsProvider);
    final route = WalkRoute(
      id: session.id,
      walkSessionId: session.id,
      points: trackPoints,
      createdAt: DateTime.now(),
    );
    await ref.read(walkSessionProvider.notifier).endWalk(route);
    ref.invalidate(walkHistoryProvider);
    ref.invalidate(walkRoutesProvider);
    ref.read(walkSessionProvider.notifier).resetWalk();
    ref.read(walkTimerProvider.notifier).reset();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WalkRoutePage(showSaveDialogOnLoad: true),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizing = AppSizingTheme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: [
                ..._buildFootprints(w, h, sizing),
                Column(
                  children: [
                    const ClockHeader(),
                    const Spacer(flex: 2),
                    FadeTransition(
                      opacity: _cardFade,
                      child: _ConfirmCard(
                        onCancel: () => Navigator.pop(context),
                        onConfirm: () => _onConfirm(),
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ],
            );
          },
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

  List<Widget> _buildFootprints(double w, double h, AppSizingTheme sizing) {
    return List.generate(_steps.length, (i) {
      final step = _steps[i];
      return Positioned(
        left: step.leftRatio * w,
        top: step.topRatio * h,
        child: FadeTransition(
          opacity: _footprintFades[i],
          child: Transform.rotate(
            angle: step.angle,
            child: ExcludeSemantics(
              child: SvgPicture.asset(
                'assets/SVG/foot2.svg',
                width: sizing.foot2Width,
                height: sizing.foot2Height,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ──────────────────────────────────────────
// 確認カード
// ──────────────────────────────────────────

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x4l),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2l,
        AppSpacing.x3l,
        AppSpacing.x2l,
        AppSpacing.x2l,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: AppSpacing.sm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppStrings.endWalkConfirmMessage,
            style: TextStyle(fontSize: AppTextStyle.lg2),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSpacing.x5l,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text(AppStrings.cancelButton),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: AppSpacing.x5l,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text(AppStrings.endWalkConfirmButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
