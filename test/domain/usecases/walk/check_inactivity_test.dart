import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/usecases/walk/check_inactivity.dart';

void main() {
  const usecase = CheckInactivity();

  group('CheckInactivity', () {
    test('10分を超えていれば true を返す', () {
      final lastAction =
          DateTime.now().subtract(const Duration(minutes: 10, seconds: 1));
      expect(usecase.call(lastAction), isTrue);
    });

    test('10分以内であれば false を返す', () {
      final lastAction =
          DateTime.now().subtract(const Duration(minutes: 9, seconds: 59));
      expect(usecase.call(lastAction), isFalse);
    });

    test('9分59秒では false を返す', () {
      final lastAction =
          DateTime.now().subtract(const Duration(minutes: 9, seconds: 59));
      expect(usecase.call(lastAction), isFalse);
    });
  });
}
