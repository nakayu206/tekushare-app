import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/data/models/saved_route_model.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/objectbox.g.dart';

/// 退会時に端末内（ObjectBox・SharedPreferences）の個人データを削除する。
class LocalDataCleaner {
  LocalDataCleaner(this._store, this._prefs);

  final Store _store;
  final SharedPreferences _prefs;

  Future<void> deleteUserData(String uid) async {
    _store
        .box<WalkSessionModel>()
        .query(WalkSessionModel_.userUid.equals(uid))
        .build()
        .remove();
    _store
        .box<WalkRouteModel>()
        .query(WalkRouteModel_.userUid.equals(uid))
        .build()
        .remove();
    _store
        .box<SavedRouteModel>()
        .query(SavedRouteModel_.userUid.equals(uid))
        .build()
        .remove();
    await _prefs.clear();
  }
}
