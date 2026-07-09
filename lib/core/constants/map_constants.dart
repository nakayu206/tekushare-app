import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

abstract class MapConstants {
  static const double defaultZoom = 17.0;
  static const double polylineStrokeWidth = 6.0;
  // 保存済みルート表示用（defaultZoom 時の基準太さ）
  static const double savedRoutePolylineStrokeWidth = 3.0;
  static const double savedRoutePolylineMinStrokeWidth = 1.5;
  static const double savedRoutePolylineMaxStrokeWidth = 8.0;
  // 保存済みルートカードのマップ操作フラグ（ピンチズーム・ダブルタップズームのみ）
  static const int savedRouteMapFlags =
      InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom;

  static double savedRouteStrokeWidthAtZoom(double zoom) =>
      (zoom / defaultZoom * savedRoutePolylineStrokeWidth).clamp(
        savedRoutePolylineMinStrokeWidth,
        savedRoutePolylineMaxStrokeWidth,
      );
  static const double photoThumbnailSize = 40.0;
  static const double photoDeleteBadgeSize = 16.0;
  static const double photoDeleteIconSize = 10.0;
  static const double photoViewerCloseIconSize = 20.0;
  static const double photoViewerCloseTapSize = 48.0;
  static const Color osmAttributionBg = Color(0xCCFFFFFF);
  static const double osmAttributionPaddingH = 6.0;
  static const double osmAttributionPaddingV = 2.0;
  static const double osmAttributionFontSize = 10.0;
  // 不活動タイマーをリセットするための最低移動距離（GPS ノイズを無視）
  static const double inactivityMinMovementMeters = 10.0;
}
