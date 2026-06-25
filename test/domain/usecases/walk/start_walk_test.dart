import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/usecases/walk/start_walk.dart';

void main() {
  const usecase = StartWalk();

  group('StartWalk', () {
    test('walking ステータスのセッションを返す', () {
      final session = usecase.call();
      expect(session.status, WalkStatus.walking);
    });

    test('startedAt が現在時刻付近にセットされる', () {
      final before = DateTime.now();
      final session = usecase.call();
      final after = DateTime.now();

      expect(session.startedAt, isNotNull);
      expect(
        session.startedAt!.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(session.startedAt!.isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });

    test('id が空でない', () {
      final session = usecase.call();
      expect(session.id, isNotEmpty);
    });

    test('elapsedSeconds の初期値が 0', () {
      final session = usecase.call();
      expect(session.elapsedSeconds, 0);
    });

    test('finishedAt は null', () {
      final session = usecase.call();
      expect(session.finishedAt, isNull);
    });
  });
}
