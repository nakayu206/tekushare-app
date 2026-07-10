import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Auth state stream ─────────────────────────────────────────────────────────

/// Firebase Auth の状態を監視する。
/// userChanges() はプロフィール更新も検知するため displayName 更新後も自動再ルーティングされる。
final authStateProvider = StreamProvider<User?>((ref) {
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
  Stream<User?> watchAuthState();
  Future<void> registerWithEmail(
      String email, String password, String displayName);
  Future<void> signInWithEmail(String email, String password);
  Future<void> setDisplayName(String name);
  Future<void> signOut();
  Future<void> deleteUser();
}

// ── Firebase Auth 実装 ────────────────────────────────────────────────────────

class FirebaseAuthServiceImpl implements AuthService {
  FirebaseAuthServiceImpl(this._auth, this._firestore);
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// アカウント連携で相手の表示名を引けるよう、Firestore側にも同期する。
  Future<void> _syncUserDoc(String uid, String displayName) {
    return _firestore.collection('users').doc(uid).set({
      'displayName': displayName,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<User?> watchAuthState() => _auth.userChanges();

  @override
  Future<void> registerWithEmail(
      String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();
    final uid = credential.user?.uid;
    if (uid != null) await _syncUserDoc(uid, displayName);
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> setDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _syncUserDoc(uid, name);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
  }
}

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

// ── Providers ─────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthServiceImpl(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

// ── Email auth notifier ───────────────────────────────────────────────────────

class EmailAuthNotifier extends StateNotifier<EmailAuthState> {
  EmailAuthNotifier(this._service) : super(const EmailAuthIdle());

  final AuthService _service;

  Future<void> register(
      String email, String password, String displayName) async {
    state = const EmailAuthLoading();
    try {
      await _service.registerWithEmail(email, password, displayName);
      state = const EmailAuthIdle();
    } on FirebaseAuthException catch (e) {
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
    } on FirebaseAuthException catch (e) {
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
