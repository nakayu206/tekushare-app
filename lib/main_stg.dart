import 'package:flutter/material.dart';

import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';

/// stg（テスト）環境のエントリーポイント
void main() {
  AppConfig.setFlavor(Flavor.stg);
  runApp(const TekuShareApp());
}
