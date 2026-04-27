import 'package:flutter/material.dart';

import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';

/// prod（リリース）環境のエントリーポイント
void main() {
  AppConfig.setFlavor(Flavor.prod);
  runApp(const TekuShareApp());
}
