import 'package:flutter/material.dart';

import 'package:tekushare/core/config/flavor.dart';

/// アプリのルートWidget
/// ルーティング・テーマ設定をここで行う
class TekuShareApp extends StatelessWidget {
  const TekuShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      home: Scaffold(
        appBar: AppBar(title: Text(AppConfig.appName)),
        body: Center(
          child: Text('Hello, ${AppConfig.appName}'),
        ),
      ),
    );
  }
}
