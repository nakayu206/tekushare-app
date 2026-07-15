import 'package:isar/isar.dart';
import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';

class WalkSessionRepositoryImpl implements WalkSessionRepository {
  WalkSessionRepositoryImpl(this._isar, this._userUid);

  final Isar _isar;
  final String _userUid;

  @override
  Future<void> saveSession(WalkSession session) async {
    await _isar.writeTxn(() async {
      await _isar.walkSessionModels
          .putByUid(WalkSessionModel.fromEntity(session, _userUid));
    });
  }

  @override
  Future<List<WalkSession>> getAllSessions() async {
    final models = await _isar.walkSessionModels
        .filter()
        .userUidEqualTo(_userUid)
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<WalkSession?> getSessionById(String id) async {
    final model = await _isar.walkSessionModels.getByUid(id);
    return model?.toEntity();
  }
}
