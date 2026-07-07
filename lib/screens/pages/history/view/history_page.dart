import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_spacing.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/constants/app_text_style.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/providers/walk_history_provider.dart';

/// 散歩履歴ページ
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(walkHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.historyPageTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text(
              AppStrings.gpsUnavailableError,
              style: TextStyle(color: AppColors.error),
            ),
          ),
          data: (sessions) {
            final finished =
                sessions.where((s) => s.status == WalkStatus.finished).toList();
            if (finished.isEmpty) {
              return const Center(
                child: Text(
                  AppStrings.historyEmpty,
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: AppTextStyle.md2,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              itemCount: finished.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _HistoryItem(
                session: finished[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalkRoutePage()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// 履歴リストアイテム
// ──────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.session, required this.onTap});

  final WalkSession session;
  final VoidCallback onTap;

  static const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

  String _formatDate(DateTime dt) {
    final w = _weekdays[dt.weekday - 1];
    return '${dt.year}年${dt.month.toString().padLeft(2, '0')}月'
        '${dt.day.toString().padLeft(2, '0')}日（$w）';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final startedAt = session.startedAt;
    final finishedAt = session.finishedAt;

    return Card(
      elevation: AppSize.cardElevation,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startedAt != null ? _formatDate(startedAt) : '-',
                style: const TextStyle(
                  fontSize: AppTextStyle.md2,
                  fontWeight: AppTextStyle.semiBold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const _Label(AppStrings.walkStartEndTime),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    startedAt != null && finishedAt != null
                        ? '${_formatTime(startedAt)}～${_formatTime(finishedAt)}'
                        : '-',
                    style: const TextStyle(
                      fontSize: AppTextStyle.sm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const _Label(AppStrings.walkDuration),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _formatDuration(session.elapsedSeconds),
                    style: const TextStyle(
                      fontSize: AppTextStyle.sm,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppTextStyle.sm,
        color: AppColors.textDisabled,
      ),
    );
  }
}
