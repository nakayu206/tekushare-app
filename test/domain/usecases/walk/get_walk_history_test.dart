import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/domain/usecases/walk/get_walk_history.dart';

import 'get_walk_history_test.mocks.dart';

@GenerateMocks([WalkSessionRepository])
void main() {
  late MockWalkSessionRepository mockRepo;
  late GetWalkHistory usecase;

  setUp(() {
    mockRepo = MockWalkSessionRepository();
    usecase = GetWalkHistory(mockRepo);
  });

  group('GetWalkHistory', () {
    test('getAllSessions の結果をそのまま返す', () async {
      final sessions = [
        const WalkSession(id: 'session-1', status: WalkStatus.finished),
        const WalkSession(id: 'session-2', status: WalkStatus.finished),
      ];
      when(mockRepo.getAllSessions()).thenAnswer((_) async => sessions);

      final result = await usecase.call();

      expect(result, sessions);
    });

    test('セッションが0件のときは空リストを返す', () async {
      when(mockRepo.getAllSessions()).thenAnswer((_) async => []);

      final result = await usecase.call();

      expect(result, isEmpty);
    });

    test('getAllSessions が1回呼ばれる', () async {
      when(mockRepo.getAllSessions()).thenAnswer((_) async => []);

      await usecase.call();

      verify(mockRepo.getAllSessions()).called(1);
    });
  });
}
