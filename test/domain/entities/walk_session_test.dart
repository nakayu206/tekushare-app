import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/entities/walk_session.dart';

void main() {
  group('WalkSession', () {
    test('デフォルト状態は idle で経過秒数 0', () {
      const session = WalkSession(id: 'session-1', status: WalkStatus.idle);

      expect(session.id, 'session-1');
      expect(session.status, WalkStatus.idle);
      expect(session.elapsedSeconds, 0);
      expect(session.startedAt, isNull);
      expect(session.finishedAt, isNull);
    });

    test('copyWith でステータスを walking に変更できる', () {
      const session = WalkSession(id: 'session-1', status: WalkStatus.idle);
      final started = DateTime(2024, 1, 1, 9, 0);
      final updated = session.copyWith(
        status: WalkStatus.walking,
        startedAt: started,
      );

      expect(updated.id, 'session-1');
      expect(updated.status, WalkStatus.walking);
      expect(updated.startedAt, started);
      expect(updated.elapsedSeconds, 0);
    });

    test('copyWith でステータスを finished に変更できる', () {
      final started = DateTime(2024, 1, 1, 9, 0);
      final finished = DateTime(2024, 1, 1, 9, 30);
      final session = WalkSession(
        id: 'session-1',
        status: WalkStatus.walking,
        startedAt: started,
        elapsedSeconds: 1800,
      );
      final updated = session.copyWith(
        status: WalkStatus.finished,
        finishedAt: finished,
      );

      expect(updated.status, WalkStatus.finished);
      expect(updated.finishedAt, finished);
      expect(updated.elapsedSeconds, 1800);
    });

    test('copyWith で変更しないフィールドは元の値を保持する', () {
      final started = DateTime(2024, 1, 1, 9, 0);
      final session = WalkSession(
        id: 'session-1',
        status: WalkStatus.walking,
        startedAt: started,
        elapsedSeconds: 60,
      );
      final updated = session.copyWith(elapsedSeconds: 120);

      expect(updated.id, 'session-1');
      expect(updated.status, WalkStatus.walking);
      expect(updated.startedAt, started);
      expect(updated.elapsedSeconds, 120);
    });

    test('copyWith で startedAt を null に戻せる', () {
      final session = WalkSession(
        id: 'session-1',
        status: WalkStatus.idle,
        startedAt: DateTime(2024, 1, 1, 9, 0),
      );
      final updated = session.copyWith(startedAt: null);

      expect(updated.startedAt, isNull);
    });

    test('copyWith で finishedAt を null に戻せる', () {
      final session = WalkSession(
        id: 'session-1',
        status: WalkStatus.finished,
        finishedAt: DateTime(2024, 1, 1, 9, 30),
      );
      final updated = session.copyWith(finishedAt: null);

      expect(updated.finishedAt, isNull);
    });
  });
}
