import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

/// アプリのルートWidget
class TekuShareApp extends StatelessWidget {
  const TekuShareApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const HomePage(),
    );
  }
}
