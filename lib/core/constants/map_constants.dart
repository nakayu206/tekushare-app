import 'package:flutter/material.dart';

abstract class MapConstants {
  static const double defaultZoom = 17.0;
  static const double polylineStrokeWidth = 3.0;
  static const double photoThumbnailSize = 40.0;
  static const double photoDeleteBadgeSize = 16.0;
  static const double photoDeleteIconSize = 10.0;
  static const Color osmAttributionBg = Color(0xCCFFFFFF);
  static const double osmAttributionPaddingH = 6.0;
  static const double osmAttributionPaddingV = 2.0;
  static const double osmAttributionFontSize = 10.0;
  // 不活動タイマーをリセットするための最低移動距離（GPS ノイズを無視）
  static const double inactivityMinMovementMeters = 10.0;
}
