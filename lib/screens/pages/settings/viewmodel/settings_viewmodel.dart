import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

typedef PhoneContact = ({String name, String phone});

class SettingsState {
  const SettingsState({
    this.timerEnabled = true,
    this.timerRoundTrip = true,
    this.timerMinutes = 30,
    this.inactivityEnabled = false,
    this.inactivityMinutes = 15,
    this.registeredContactName,
    this.shareWantToGo = true,
    this.shareVisited = true,
    this.inviteLink,
    this.isEditingSharedAccounts = false,
  });

  final bool timerEnabled;
  final bool timerRoundTrip;
  final int timerMinutes;
  final bool inactivityEnabled;
  final int inactivityMinutes;
  final String? registeredContactName;
  final bool shareWantToGo;
  final bool shareVisited;
  final String? inviteLink;
  final bool isEditingSharedAccounts;

  SettingsState copyWith({
    bool? timerEnabled,
    bool? timerRoundTrip,
    int? timerMinutes,
    bool? inactivityEnabled,
    int? inactivityMinutes,
    String? registeredContactName,
    bool? shareWantToGo,
    bool? shareVisited,
    String? inviteLink,
    bool? isEditingSharedAccounts,
  }) =>
      SettingsState(
        timerEnabled: timerEnabled ?? this.timerEnabled,
        timerRoundTrip: timerRoundTrip ?? this.timerRoundTrip,
        timerMinutes: timerMinutes ?? this.timerMinutes,
        inactivityEnabled: inactivityEnabled ?? this.inactivityEnabled,
        inactivityMinutes: inactivityMinutes ?? this.inactivityMinutes,
        registeredContactName:
            registeredContactName ?? this.registeredContactName,
        shareWantToGo: shareWantToGo ?? this.shareWantToGo,
        shareVisited: shareVisited ?? this.shareVisited,
        inviteLink: inviteLink ?? this.inviteLink,
        isEditingSharedAccounts:
            isEditingSharedAccounts ?? this.isEditingSharedAccounts,
      );
}

class SettingsViewModel extends Notifier<SettingsState> {
  static const _kTimerEnabled = 'settings_timerEnabled';
  static const _kTimerRoundTrip = 'settings_timerRoundTrip';
  static const _kTimerMinutes = 'settings_timerMinutes';
  static const _kInactivityEnabled = 'settings_inactivityEnabled';
  static const _kInactivityMinutes = 'settings_inactivityMinutes';
  static const _kRegisteredContactName = 'settings_registeredContactName';

  @override
  SettingsState build() {
    final prefsAsync = ref.watch(sharedPrefsProvider);
    // 共有設定はアカウントごとの値なので、ユーザーが切り替わるたびにサーバーから読み直す
    final uid = ref.watch(authStateProvider.select((a) => a.valueOrNull?.uid));
    if (uid != null) Future.microtask(_loadShareSettings);
    return prefsAsync.when(
      data: (prefs) => SettingsState(
        timerEnabled: prefs.getBool(_kTimerEnabled) ?? true,
        timerRoundTrip: prefs.getBool(_kTimerRoundTrip) ?? true,
        timerMinutes: prefs.getInt(_kTimerMinutes) ?? 30,
        inactivityEnabled: prefs.getBool(_kInactivityEnabled) ?? false,
        inactivityMinutes: prefs.getInt(_kInactivityMinutes) ?? 15,
        registeredContactName: prefs.getString(_kRegisteredContactName),
      ),
      loading: () => const SettingsState(),
      error: (_, __) => const SettingsState(),
    );
  }

  /// 共有設定はサーバーの値を正とする（端末にはキャッシュしない）
  Future<void> _loadShareSettings() async {
    try {
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (uid == null) return;
      final settings =
          await ref.read(accountLinkRepositoryProvider).fetchShareSettings(uid);
      // 取得中にユーザーが切り替わっていたら破棄する
      if (ref.read(authStateProvider).valueOrNull?.uid != uid) return;
      state = state.copyWith(
        shareWantToGo: settings.shareWantToGo,
        shareVisited: settings.shareVisited,
      );
    } catch (_) {
      // 取得できない場合は現在の表示を維持する
    }
  }

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider).requireValue;

  void setTimerEnabled(bool v) {
    _prefs.setBool(_kTimerEnabled, v);
    state = state.copyWith(timerEnabled: v);
  }

  void setTimerRoundTrip(bool v) {
    _prefs.setBool(_kTimerRoundTrip, v);
    state = state.copyWith(timerRoundTrip: v);
  }

  void setTimerMinutes(int v) {
    _prefs.setInt(_kTimerMinutes, v);
    state = state.copyWith(timerMinutes: v);
  }

  void setInactivityEnabled(bool v) {
    _prefs.setBool(_kInactivityEnabled, v);
    state = state.copyWith(inactivityEnabled: v);
  }

  void setInactivityMinutes(int v) {
    _prefs.setInt(_kInactivityMinutes, v);
    state = state.copyWith(inactivityMinutes: v);
  }

  void registerContact(String name) {
    _prefs.setString(_kRegisteredContactName, name);
    state = state.copyWith(registeredContactName: name);
  }

  Future<void> setShareWantToGo(bool v) async {
    final prev = state.shareWantToGo;
    state = state.copyWith(shareWantToGo: v);
    try {
      await ref.read(accountLinkRepositoryProvider).updateShareSettings(
            shareWantToGo: v,
            shareVisited: state.shareVisited,
          );
    } catch (_) {
      state = state.copyWith(shareWantToGo: prev);
    }
  }

  Future<void> setShareVisited(bool v) async {
    final prev = state.shareVisited;
    state = state.copyWith(shareVisited: v);
    try {
      await ref.read(accountLinkRepositoryProvider).updateShareSettings(
            shareWantToGo: state.shareWantToGo,
            shareVisited: v,
          );
    } catch (_) {
      state = state.copyWith(shareVisited: prev);
    }
  }

  void toggleEditSharedAccounts() => state = state.copyWith(
        isEditingSharedAccounts: !state.isEditingSharedAccounts,
      );

  Future<void> unlinkAccount(String uid) {
    return ref.read(accountLinkRepositoryProvider).unlink(uid);
  }

  Future<void> generateInviteLink() async {
    final link =
        await ref.read(accountLinkRepositoryProvider).createInviteLink();
    state = state.copyWith(inviteLink: link);
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
