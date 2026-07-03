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
      expect(state().shareWantToGo, true);
      expect(state().shareVisited, true);
      expect(state().sharedAccounts, ['あかり', 'たかし', 'ゆか', 'けんじ']);
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

    // 共有アカウント消去
    test('removeSharedAccount removes the specified account', () {
      vm().removeSharedAccount('たかし');
      expect(state().sharedAccounts, ['あかり', 'ゆか', 'けんじ']);
    });

    // 存在しないアカウントの消去は何もしない
    test('removeSharedAccount with unknown name does not change list', () {
      vm().removeSharedAccount('存在しない');
      expect(state().sharedAccounts, ['あかり', 'たかし', 'ゆか', 'けんじ']);
    });

    // ログアウト（スタブ：状態変化なし）
    test('logout does not throw', () {
      expect(() => vm().logout(), returnsNormally);
    });

    // アカウント消去（スタブ：状態変化なし）
    test('deleteAccount does not throw', () {
      expect(() => vm().deleteAccount(), returnsNormally);
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
