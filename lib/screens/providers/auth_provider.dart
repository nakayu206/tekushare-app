import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── ドメイン型 ─────────────────────────────────────────────────────────────────

class AuthUser {
  const AuthUser({required this.uid, this.displayName});
  final String uid;
  final String? displayName;
}

class AuthException implements Exception {
  const AuthException(this.code);
  final String code;
}

// ── Auth state stream ─────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).watchAuthState();
});

// ── Email auth UI state ───────────────────────────────────────────────────────

sealed class EmailAuthState {
  const EmailAuthState();
}

class EmailAuthIdle extends EmailAuthState {
  const EmailAuthIdle();
}

class EmailAuthLoading extends EmailAuthState {
  const EmailAuthLoading();
}

class EmailAuthError extends EmailAuthState {
  const EmailAuthError(this.message);
  final String message;
}

// ── Auth service interface ────────────────────────────────────────────────────

abstract interface class AuthService {
  Stream<AuthUser?> watchAuthState();
  Future<void> registerWithEmail(
      String email, String password, String displayName);
  Future<void> signInWithEmail(String email, String password);
  Future<void> setDisplayName(String name);
  Future<void> signOut();
  Future<void> deleteUser();
}

// ── Provider declaration ──────────────────────────────────────────────────────
// 実装は ProviderScope.overrides（main_*.dart）で注入する。

final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError(
      'authServiceProvider must be overridden in ProviderScope');
});

// ── Email auth notifier ───────────────────────────────────────────────────────

String _mapErrorCode(String code) {
  return switch (code) {
    'email-already-in-use' => 'このメールアドレスはすでに使われています',
    'invalid-email' => 'メールアドレスの形式が正しくありません',
    'weak-password' => 'パスワードは6文字以上で入力してください',
    'user-not-found' => 'このメールアドレスは登録されていません',
    'wrong-password' => 'パスワードが間違っています',
    'invalid-credential' => 'メールアドレスまたはパスワードが間違っています',
    'too-many-requests' => 'しばらく時間をおいてから再度お試しください',
    _ => '認証エラーが発生しました（$code）',
  };
}

class EmailAuthNotifier extends StateNotifier<EmailAuthState> {
  EmailAuthNotifier(this._service) : super(const EmailAuthIdle());

  final AuthService _service;

  Future<void> register(
      String email, String password, String displayName) async {
    state = const EmailAuthLoading();
    try {
      await _service.registerWithEmail(email, password, displayName);
      state = const EmailAuthIdle();
    } on AuthException catch (e) {
      state = EmailAuthError(_mapErrorCode(e.code));
    } catch (_) {
      state = const EmailAuthError('エラーが発生しました');
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const EmailAuthLoading();
    try {
      await _service.signInWithEmail(email, password);
      state = const EmailAuthIdle();
    } on AuthException catch (e) {
      state = EmailAuthError(_mapErrorCode(e.code));
    } catch (_) {
      state = const EmailAuthError('エラーが発生しました');
    }
  }

  void reset() => state = const EmailAuthIdle();
}

final emailAuthProvider =
    StateNotifierProvider<EmailAuthNotifier, EmailAuthState>((ref) {
  return EmailAuthNotifier(ref.watch(authServiceProvider));
});

// ── Display name notifier ─────────────────────────────────────────────────────

class DisplayNameNotifier extends StateNotifier<AsyncValue<void>> {
  DisplayNameNotifier(this._service) : super(const AsyncData(null));

  final AuthService _service;

  Future<void> save(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.setDisplayName(name));
  }
}

final displayNameProvider =
    StateNotifierProvider<DisplayNameNotifier, AsyncValue<void>>((ref) {
  return DisplayNameNotifier(ref.watch(authServiceProvider));
});
