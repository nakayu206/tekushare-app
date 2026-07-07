import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/screens/pages/history/view/history_page.dart';
import 'package:tekushare/screens/providers/walk_history_provider.dart';

// ──────────────────────────────────────────
// ヘルパー
// ──────────────────────────────────────────

Future<void> pumpHistoryPage(
  WidgetTester tester, {
  required List<WalkSession> sessions,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        walkHistoryProvider.overrideWith((_) async => sessions),
      ],
      child: MaterialApp(
        builder: (context, child) {
          final sw = MediaQuery.sizeOf(context).width;
          return Theme(
            data: Theme.of(context).copyWith(
              extensions: [AppSizingTheme.fromScreenWidth(sw)],
            ),
            child: child!,
          );
        },
        home: const HistoryPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

WalkSession _makeSession({
  required DateTime startedAt,
  required DateTime finishedAt,
  int elapsedSeconds = 900,
}) =>
    WalkSession(
      id: 'test-id',
      status: WalkStatus.finished,
      startedAt: startedAt,
      finishedAt: finishedAt,
      elapsedSeconds: elapsedSeconds,
    );

// ──────────────────────────────────────────
// テスト
// ──────────────────────────────────────────

void main() {
  group('HistoryPage', () {
    // 履歴が空のとき空状態メッセージを表示する
    testWidgets('shows empty message when no history', (tester) async {
      await pumpHistoryPage(tester, sessions: []);

      expect(find.text(AppStrings.historyEmpty), findsOneWidget);
    });

    // 履歴があるとき日付が表示される
    testWidgets('shows session date', (tester) async {
      final session = _makeSession(
        startedAt: DateTime(2026, 2, 7, 9, 0),
        finishedAt: DateTime(2026, 2, 7, 9, 15),
        elapsedSeconds: 900,
      );

      await pumpHistoryPage(tester, sessions: [session]);

      expect(find.textContaining('2026年02月07日'), findsOneWidget);
    });

    // 開始〜終了時刻が表示される
    testWidgets('shows start and end time', (tester) async {
      final session = _makeSession(
        startedAt: DateTime(2026, 2, 7, 9, 0),
        finishedAt: DateTime(2026, 2, 7, 9, 15),
      );

      await pumpHistoryPage(tester, sessions: [session]);

      expect(find.textContaining('9:00～9:15'), findsOneWidget);
    });

    // 経過時間が表示される
    testWidgets('shows elapsed duration', (tester) async {
      final session = _makeSession(
        startedAt: DateTime(2026, 2, 7, 9, 0),
        finishedAt: DateTime(2026, 2, 7, 9, 15),
        elapsedSeconds: 900,
      );

      await pumpHistoryPage(tester, sessions: [session]);

      expect(find.textContaining('15:00'), findsOneWidget);
    });

    // タップで WalkRoutePage へ遷移する
    testWidgets('navigates to WalkRoutePage on item tap', (tester) async {
      final session = _makeSession(
        startedAt: DateTime(2026, 2, 7, 9, 0),
        finishedAt: DateTime(2026, 2, 7, 9, 15),
      );

      await pumpHistoryPage(tester, sessions: [session]);

      await tester.tap(find.textContaining('2026年02月07日'));
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // ローディング中はインジケーターを表示する
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walkHistoryProvider.overrideWith(
              (_) => Completer<List<WalkSession>>().future,
            ),
          ],
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const HistoryPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
