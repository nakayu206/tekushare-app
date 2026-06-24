import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';

void main() {
  group('LatLng', () {
    test('同じ座標は等しい', () {
      const a = LatLng(35.6895, 139.6917);
      const b = LatLng(35.6895, 139.6917);

      expect(a, equals(b));
    });

    test('異なる座標は等しくない', () {
      const a = LatLng(35.6895, 139.6917);
      const b = LatLng(34.6937, 135.5023);

      expect(a, isNot(equals(b)));
    });

    test('同じ座標は hashCode が一致する', () {
      const a = LatLng(35.6895, 139.6917);
      const b = LatLng(35.6895, 139.6917);

      expect(a.hashCode, b.hashCode);
    });
  });
}
