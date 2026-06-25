import 'package:tekushare/domain/entities/walk_session.dart';

abstract interface class WalkSessionRepository {
  Future<void> saveSession(WalkSession session);
  Future<List<WalkSession>> getAllSessions();
  Future<WalkSession?> getSessionById(String id);
}
