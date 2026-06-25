import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';

class GetWalkHistory {
  const GetWalkHistory(this._repository);

  final WalkSessionRepository _repository;

  Future<List<WalkSession>> call() {
    return _repository.getAllSessions();
  }
}
