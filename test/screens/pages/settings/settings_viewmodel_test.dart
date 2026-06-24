import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/screens/pages/settings/viewmodel/settings_viewmodel.dart';

void main() {
  group('SettingsViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
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
      expect(state().shareSpots, false);
      expect(state().shareRoutes, false);
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

    // 行きたいリスト共有
    test('setShareSpots updates shareSpots', () {
      vm().setShareSpots(true);
      expect(state().shareSpots, true);
    });

    // 散歩ルート共有
    test('setShareRoutes updates shareRoutes', () {
      vm().setShareRoutes(true);
      expect(state().shareRoutes, true);
    });

    // 他フィールドに影響しない
    test('updating one field does not affect others', () {
      vm().setTimerEnabled(false);
      expect(state().timerRoundTrip, true);
      expect(state().timerMinutes, 30);
      expect(state().inactivityEnabled, false);
    });
  });
}
