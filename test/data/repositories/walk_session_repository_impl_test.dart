import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/data/repositories/walk_session_repository_impl.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/objectbox.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Store store;
  late WalkSessionRepositoryImpl repo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ob_session_');
    store = await openStore(directory: tempDir.path);
    repo = WalkSessionRepositoryImpl(store, 'user-1');
  });

  tearDown(() {
    store.close();
    tempDir.deleteSync(recursive: true);
  });

  WalkSession makeSession({
    String id = 'session-1',
    WalkStatus status = WalkStatus.idle,
  }) {
    return WalkSession(id: id, status: status);
  }

  group('WalkSessionRepositoryImpl', () {
    test('saveSession で保存したセッションを getAllSessions で取得できる', () async {
      await repo.saveSession(makeSession());

      final result = await repo.getAllSessions();
      expect(result.length, 1);
      expect(result.first.id, 'session-1');
      expect(result.first.status, WalkStatus.idle);
    });

    test('getSessionById で id に対応するセッションを取得できる', () async {
      await repo.saveSession(makeSession(id: 'session-a'));
      await repo.saveSession(
          makeSession(id: 'session-b', status: WalkStatus.walking));

      final result = await repo.getSessionById('session-b');
      expect(result?.id, 'session-b');
      expect(result?.status, WalkStatus.walking);
    });

    test('getSessionById で存在しない id は null を返す', () async {
      final result = await repo.getSessionById('no-such-id');
      expect(result, isNull);
    });

    test('saveSession は同じ id で upsert される', () async {
      await repo.saveSession(makeSession());
      final updated = WalkSession(
        id: 'session-1',
        status: WalkStatus.walking,
        startedAt: DateTime(2024, 1, 1, 9, 0),
        elapsedSeconds: 60,
      );
      await repo.saveSession(updated);

      final result = await repo.getAllSessions();
      expect(result.length, 1);
      expect(result.first.status, WalkStatus.walking);
      expect(result.first.elapsedSeconds, 60);
    });
  });
}
