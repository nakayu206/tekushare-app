import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/app.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/walk/view/walk_page.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/clock_header.dart';
import 'package:tekushare/screens/widgets/common/primary_button.dart';

/// ホーム画面
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _controller;
  late List<Animation<double>> _footprintFades;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    if (ref.read(walkSessionProvider).status == WalkStatus.walking) {
      // pop() のロック解除後（マイクロタスク）に push する。
      // 直接呼ぶと Navigator がロック中で _debugLocked アサーションが発生する。
      Future.microtask(() {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalkPage()),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    // 足あと: 0.0〜0.857 の区間で1本ずつ順番にフェードイン
    const footprintEnd = 0.857;
    final count = _FootprintSection._steps.length;
    _footprintFades = List.generate(count, (i) {
      final start = (i / count) * footprintEnd;
      final end = ((i + 1) / count) * footprintEnd;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _controller.forward();

    // プロセスキル後の復元: SharedPreferences から walking 状態が復元されていたら
    // ref.listen は初期値で発火しないため、initState で明示的にチェックして遷移する
    Future.microtask(() {
      if (!mounted) return;
      if (ref.read(walkSessionProvider).status == WalkStatus.walking) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalkPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WalkSession>(walkSessionProvider, (previous, next) {
      if (next.status == WalkStatus.walking && next.id != previous?.id) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalkPage()),
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 画面高さの 38% を上限 280px としてフットプリントエリアを確保
              final footprintHeight =
                  (constraints.maxHeight * 0.38).clamp(0.0, 280.0);
              return Column(
                children: [
                  const ClockHeader(),
                  const Spacer(flex: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2l,
                    ),
                    child: PrimaryButton(
                      label: AppStrings.startWalk,
                      onPressed: () =>
                          ref.read(walkSessionProvider.notifier).startWalk(),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: footprintHeight,
                    child: _FootprintSection(footprintFades: _footprintFades),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 0,
          onTap: (index) {
            if (index == 1 && ModalRoute.of(context)?.isCurrent == true) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SpotListPage()),
                (route) => route.isFirst,
              );
            } else if (index == 2 &&
                ModalRoute.of(context)?.isCurrent == true) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WalkRoutePage()),
                (route) => route.isFirst,
              );
            } else if (index == 3 &&
                ModalRoute.of(context)?.isCurrent == true) {
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
// 足あとアニメーション
// ──────────────────────────────────────────

class _FootprintSection extends StatelessWidget {
  const _FootprintSection({required this.footprintFades});

  final List<Animation<double>> footprintFades;

  // dx: 中心からの横オフセット, dy: 下からの距離, angle: 回転（ラジアン）
  static const _steps = [
    (dx: -22.0, dy: 10.0, angle: 0.0),
    (dx: -32.0, dy: 73.0, angle: -0.3),
    (dx: -8.0, dy: 140.0, angle: 0.0),
    (dx: -18.0, dy: 198.0, angle: -0.3),
  ];

  // デザイン基準の高さ（280dp 時のサイズ・位置で設計）
  static const double _designHeight = 280.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final scale = (constraints.maxHeight / _designHeight).clamp(0.0, 1.0);
        final fw = _Footprint.w * scale;
        final fh = _Footprint.h * scale;

        return Stack(
          children: List.generate(_steps.length, (i) {
            final step = _steps[i];

            return Positioned(
              left: centerX + step.dx - fw / 2,
              bottom: step.dy * scale,
              child: FadeTransition(
                opacity: footprintFades[i],
                child: _Footprint(
                  angle: step.angle,
                  width: fw,
                  height: fh,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Footprint extends StatelessWidget {
  const _Footprint({
    required this.angle,
    required this.width,
    required this.height,
  });

  static const double w = 56.0;
  static const double h = 73.0;

  final double angle;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SvgPicture.asset(
        'assets/SVG/foot.svg',
        width: width,
        height: height,
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}
