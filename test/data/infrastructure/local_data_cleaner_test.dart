import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/data/models/saved_route_model.dart';
import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/infrastructure/local_data_cleaner.dart';
import 'package:tekushare/objectbox.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Store store;
  late SharedPreferences prefs;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ob_cleaner_');
    store = await openStore(directory: tempDir.path);
    SharedPreferences.setMockInitialValues({'settings_timerEnabled': false});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() {
    store.close();
    tempDir.deleteSync(recursive: true);
  });

  SavedRouteModel route(String uid) => SavedRouteModel()
    ..userUid = uid
    ..name = 'r'
    ..date = 'd'
    ..distance = '1'
    ..time = '1'
    ..createdAt = DateTime(2026);

  test('指定ユーザーのデータだけを削除し、設定を初期化する', () async {
    final box = store.box<SavedRouteModel>();
    box.putMany([route('me'), route('other')]);

    await LocalDataCleaner(store, prefs).deleteUserData('me');

    expect(box.getAll().map((r) => r.userUid), ['other']);
    expect(store.box<WalkSessionModel>().isEmpty(), true);
    expect(prefs.getKeys(), isEmpty);
  });
}
