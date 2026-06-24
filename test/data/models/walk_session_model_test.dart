import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/domain/entities/walk_session.dart';

void main() {
  group('WalkSessionModel', () {
    test('fromEntity で idle セッションを変換できる', () {
      const session = WalkSession(status: WalkStatus.idle);
      final model = WalkSessionModel.fromEntity('session-1', session);

      expect(model.uid, 'session-1');
      expect(model.status, WalkStatus.idle);
      expect(model.startedAt, isNull);
      expect(model.finishedAt, isNull);
      expect(model.elapsedSeconds, 0);
    });

    test('fromEntity で finished セッションを変換できる', () {
      final startedAt = DateTime(2024, 1, 1, 9, 0);
      final finishedAt = DateTime(2024, 1, 1, 9, 30);
      final session = WalkSession(
        status: WalkStatus.finished,
        startedAt: startedAt,
        finishedAt: finishedAt,
        elapsedSeconds: 1800,
      );
      final model = WalkSessionModel.fromEntity('session-1', session);

      expect(model.status, WalkStatus.finished);
      expect(model.startedAt, startedAt);
      expect(model.finishedAt, finishedAt);
      expect(model.elapsedSeconds, 1800);
    });

    test('toEntity でモデルからエンティティに変換できる', () {
      final startedAt = DateTime(2024, 1, 1, 9, 0);
      final session = WalkSession(
        status: WalkStatus.walking,
        startedAt: startedAt,
        elapsedSeconds: 300,
      );
      final model = WalkSessionModel.fromEntity('session-1', session);
      final restored = model.toEntity();

      expect(restored.status, WalkStatus.walking);
      expect(restored.startedAt, startedAt);
      expect(restored.elapsedSeconds, 300);
    });
  });
}
