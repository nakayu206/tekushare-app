import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/firebase_options.dart';
import 'package:tekushare/infrastructure/notification_service.dart';
import 'package:tekushare/screens/providers/firebase_providers.dart';

/// dev環境のエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await NotificationService.instance.initialize();
  } catch (_) {}
  AppConfig.setFlavor(Flavor.dev);
  runApp(
    ProviderScope(
      overrides: firebaseProviderOverrides(),
      child: const TekuShareApp(),
    ),
  );
}
