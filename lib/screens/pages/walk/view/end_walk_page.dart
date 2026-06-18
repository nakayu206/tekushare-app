import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';
import 'package:tekushare/screens/widgets/common/clock_header.dart';

/// 散歩終了確認ページ
class EndWalkPage extends StatefulWidget {
  const EndWalkPage({super.key});

  @override
  State<EndWalkPage> createState() => _EndWalkPageState();
}

class _EndWalkPageState extends State<EndWalkPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _footprintFades;
  late Animation<double> _cardFade;

  // (left, top, angle) — SafeAreaからの絶対座標
  // 左右交互に配置して歩いている感じを表現
  static const _steps = [
    (left: -15.0, top: 190.0, angle: 0.1), // 左足
    (left: 50.0, top: 210.0, angle: -0.4), // 右足
    (left: 75.0, top: 268.0, angle: 0.1), // 左足
    (left: 140.0, top: 288.0, angle: -0.4), // 右足
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ..._buildFootprints(),
            Column(
              children: [
                const ClockHeader(),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _cardFade,
                  child: _ConfirmCard(
                    onCancel: () => Navigator.pop(context),
                    onConfirm: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpotListPage()),
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildFootprints() {
    return List.generate(_steps.length, (i) {
      final step = _steps[i];
      return Positioned(
        left: step.left,
        top: step.top,
        child: FadeTransition(
          opacity: _footprintFades[i],
          child: Transform.rotate(
            angle: step.angle,
            child: SvgPicture.asset(
              'assets/SVG/foot2.svg',
              width: 33,
              height: 49,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 125,
                height: 48,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(AppStrings.cancelButton),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 125,
                height: 48,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(AppStrings.endWalkConfirmButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
