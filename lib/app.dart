import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/pages/auth/view/display_name_page.dart';
import 'package:tekushare/screens/pages/auth/view/email_auth_page.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

/// アプリのルートWidget
class TekuShareApp extends ConsumerWidget {
  const TekuShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(appReadyProvider);
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.zenMaruGothicTextTheme(),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final sw = MediaQuery.sizeOf(context).width;
        return Theme(
          data: Theme.of(context).copyWith(
            extensions: [AppSizingTheme.fromScreenWidth(sw)],
          ),
          child: child!,
        );
      },
      home: ready.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('DB初期化エラー: $e'))),
        data: (_) => authState.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('認証エラー: $e'))),
          data: (user) {
            if (user == null) return const EmailAuthPage();
            final name = user.displayName;
            // null は Firebase がプロフィールを同期中の一時状態。
            // ローディングを挟み DisplayNamePage が誤表示されるのを防ぐ。
            if (name == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (name.isEmpty) return const DisplayNamePage();
            return const HomePage();
          },
        ),
      ),
    );
  }
}
