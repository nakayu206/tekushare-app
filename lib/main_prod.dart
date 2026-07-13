import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/data/services/firebase_auth_service_impl.dart';
import 'package:tekushare/firebase_options.dart';
import 'package:tekushare/infrastructure/notification_service.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// prod（リリース）環境のエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await NotificationService.instance.initialize();
  } catch (_) {}
  AppConfig.setFlavor(Flavor.prod);
  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(
          FirebaseAuthServiceImpl(
            FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
      ],
      child: const TekuShareApp(),
    ),
  );
}
