import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

/// アプリのルートWidget
class TekuShareApp extends ConsumerWidget {
  const TekuShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarState = ref.watch(isarProvider);
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.zenMaruGothicTextTheme(),
        useMaterial3: true,
      ),
      home: isarState.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('DB初期化エラー: $e'))),
        data: (_) => const HomePage(),
      ),
    );
  }
}
