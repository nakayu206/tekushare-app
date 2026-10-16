import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tekushare/domain/entities/app_update.dart';

/// Firebaseへの接続は起動時のoverrideで注入する。
final appUpdateLoaderProvider = Provider<Future<AppUpdate?> Function()>((ref) {
  return () async => null;
});

/// インストール済みアプリの実際のビルド番号を取得する。
final installedBuildLoaderProvider = Provider<Future<int> Function()>((ref) {
  return () async => 0;
});

/// 設定未登録・取得失敗時には通常どおり起動できるようにする。
final appUpdateProvider = FutureProvider<AppUpdate?>((ref) async {
  try {
    return await ref
        .watch(appUpdateLoaderProvider)()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('更新設定の取得に失敗しました: $e');
    return null;
  }
});
