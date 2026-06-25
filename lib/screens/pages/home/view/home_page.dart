import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _footprintFades;
  late Animation<double> _buttonFade;

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

    // ボタン: 全足あとが出揃ったあとにフェードイン
    _buttonFade = CurvedAnimation(
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

  @override
  Widget build(BuildContext context) {
    ref.listen<WalkSession>(walkSessionProvider, (previous, next) {
      if (next.status == WalkStatus.walking &&
          previous?.status != WalkStatus.walking) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalkPage()),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ClockHeader(),
            const Spacer(flex: 8),
            FadeTransition(
              opacity: _buttonFade,
              child: PrimaryButton(
                label: AppStrings.startWalk,
                onPressed: () =>
                    ref.read(walkSessionProvider.notifier).startWalk(),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 280,
              child: _FootprintSection(footprintFades: _footprintFades),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1 && ModalRoute.of(context)?.isCurrent == true) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpotListPage()),
            );
          } else if (index == 2 && ModalRoute.of(context)?.isCurrent == true) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;

        return Stack(
          children: List.generate(_steps.length, (i) {
            final step = _steps[i];

            return Positioned(
              left: centerX + step.dx - _Footprint.w / 2,
              bottom: step.dy,
              child: FadeTransition(
                opacity: footprintFades[i],
                child: _Footprint(angle: step.angle),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Footprint extends StatelessWidget {
  const _Footprint({required this.angle});

  static const double w = 56.0;
  static const double h = 73.0;

  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SvgPicture.asset(
        'assets/SVG/foot.svg',
        width: w,
        height: h,
        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }
}
