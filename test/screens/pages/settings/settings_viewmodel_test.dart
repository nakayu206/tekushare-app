import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/screens/pages/settings/viewmodel/settings_viewmodel.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

void main() {
  group('SettingsViewModel', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      // prefs ロード完了を待ってから各テストへ
      await container.read(sharedPrefsProvider.future);
    });

    tearDown(() {
      container.dispose();
    });

    SettingsState state() => container.read(settingsViewModelProvider);
    SettingsViewModel vm() =>
        container.read(settingsViewModelProvider.notifier);

    // 初期状態の確認
    test('initial state has correct defaults', () {
      expect(state().timerEnabled, true);
      expect(state().timerRoundTrip, true);
      expect(state().timerMinutes, 30);
      expect(state().inactivityEnabled, false);
      expect(state().inactivityMinutes, 15);
      expect(state().registeredContactName, null);
      expect(state().shareWantToGo, true);
      expect(state().shareVisited, true);
      expect(state().inviteLink, null);
      expect(state().isEditingSharedAccounts, false);
    });

    // タイマーON/OFF
    test('setTimerEnabled updates timerEnabled', () {
      vm().setTimerEnabled(false);
      expect(state().timerEnabled, false);
      vm().setTimerEnabled(true);
      expect(state().timerEnabled, true);
    });

    // 片道/往復
    test('setTimerRoundTrip updates timerRoundTrip', () {
      vm().setTimerRoundTrip(false);
      expect(state().timerRoundTrip, false);
    });

    // タイマー分数
    test('setTimerMinutes updates timerMinutes', () {
      vm().setTimerMinutes(60);
      expect(state().timerMinutes, 60);
    });

    // 安否確認ON/OFF
    test('setInactivityEnabled updates inactivityEnabled', () {
      vm().setInactivityEnabled(true);
      expect(state().inactivityEnabled, true);
    });

    // 安否確認分数
    test('setInactivityMinutes updates inactivityMinutes', () {
      vm().setInactivityMinutes(30);
      expect(state().inactivityMinutes, 30);
    });

    // 通知先登録
    test('registerContact updates registeredContactName', () {
      vm().registerContact('山田 太郎');
      expect(state().registeredContactName, '山田 太郎');
    });

    // 行きたい！リスト共有
    test('setShareWantToGo updates shareWantToGo', () {
      vm().setShareWantToGo(false);
      expect(state().shareWantToGo, false);
    });

    // 行った！リスト共有
    test('setShareVisited updates shareVisited', () {
      vm().setShareVisited(false);
      expect(state().shareVisited, false);
    });

    // 連携アカウント一覧の編集モード切り替え
    test('toggleEditSharedAccounts flips isEditingSharedAccounts', () {
      vm().toggleEditSharedAccounts();
      expect(state().isEditingSharedAccounts, true);
      vm().toggleEditSharedAccounts();
      expect(state().isEditingSharedAccounts, false);
    });

    // 他フィールドに影響しない
    test('updating one field does not affect others', () {
      vm().setTimerEnabled(false);
      expect(state().timerRoundTrip, true);
      expect(state().timerMinutes, 30);
      expect(state().inactivityEnabled, false);
    });

    // 永続化確認: 変更値が prefs に保存され再読み込みで復元される
    test('persisted values are restored in new container', () async {
      vm().setTimerEnabled(false);
      vm().setTimerMinutes(45);
      vm().setInactivityEnabled(true);

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      await container2.read(sharedPrefsProvider.future);

      final state2 = container2.read(settingsViewModelProvider);
      expect(state2.timerEnabled, false);
      expect(state2.timerMinutes, 45);
      expect(state2.inactivityEnabled, true);
    });
  });
}
