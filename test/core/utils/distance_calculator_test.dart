import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/utils/distance_calculator.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';

void main() {
  group('calcDistanceKm', () {
    test('returns 0 for empty list', () {
      expect(calcDistanceKm([]), 0);
    });

    test('returns 0 for single point', () {
      expect(calcDistanceKm([const LatLng(35.0, 139.0)]), 0);
    });

    test('calculates distance for two points approximately 1km apart', () {
      // 35.000→35.009 ≈ 1.0km（緯度1度≈111km）
      final km = calcDistanceKm([
        const LatLng(35.000, 139.000),
        const LatLng(35.009, 139.000),
      ]);
      expect(km, closeTo(1.0, 0.05));
    });

    test('accumulates distances across multiple segments without rounding', () {
      // 3点を通る経路: 各区間を個別に計算して合計したものと一致する
      const points = [
        LatLng(35.000, 139.000),
        LatLng(35.004, 139.000),
        LatLng(35.009, 139.000),
      ];
      final total = calcDistanceKm(points);
      final seg1 = calcDistanceKm([points[0], points[1]]);
      final seg2 = calcDistanceKm([points[1], points[2]]);
      expect(total, closeTo(seg1 + seg2, 1e-10));
    });
  });

  group('formatDistanceKm', () {
    test('returns - for zero distance', () {
      expect(formatDistanceKm(0), '-');
    });

    test('formats as meters when less than 1km', () {
      expect(formatDistanceKm(0.5), '500m');
      expect(formatDistanceKm(0.8), '800m');
    });

    test('formats as km with one decimal when 1km or more', () {
      expect(formatDistanceKm(1.0), '1.0km');
      expect(formatDistanceKm(1.234), '1.2km');
      expect(formatDistanceKm(2.5), '2.5km');
    });
  });
}
