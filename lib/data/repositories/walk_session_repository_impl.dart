import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/objectbox.g.dart';

class WalkSessionRepositoryImpl implements WalkSessionRepository {
  WalkSessionRepositoryImpl(Store store, this._userUid)
      : _box = store.box<WalkSessionModel>();

  final Box<WalkSessionModel> _box;
  final String _userUid;

  @override
  Future<void> saveSession(WalkSession session) async {
    final model = WalkSessionModel.fromEntity(session, _userUid);
    final existing = _box
        .query(WalkSessionModel_.uid.equals(session.id))
        .build()
        .findFirst();
    if (existing != null) model.id = existing.id;
    _box.put(model);
  }

  @override
  Future<List<WalkSession>> getAllSessions() async {
    final models =
        _box.query(WalkSessionModel_.userUid.equals(_userUid)).build().find();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<WalkSession?> getSessionById(String id) async {
    final model =
        _box.query(WalkSessionModel_.uid.equals(id)).build().findFirst();
    if (model == null || model.userUid != _userUid) return null;
    return model.toEntity();
  }
}
