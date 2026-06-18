import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/screens/widgets/common/dashed_border_painter.dart';

void main() {
  group('DashedBorderPainter', () {
    test('shouldRepaint は常に false を返す', () {
      const painter = DashedBorderPainter();
      expect(painter.shouldRepaint(const DashedBorderPainter()), isFalse);
    });
  });
}
