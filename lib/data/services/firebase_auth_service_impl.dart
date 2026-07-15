import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

class FirebaseAuthServiceImpl implements AuthService {
  FirebaseAuthServiceImpl(this._auth, this._firestore) {
    _auth.setLanguageCode('ja');
  }
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// アカウント連携で相手の表示名を引けるよう、Firestore側にも同期する。
  /// 付随的な処理なので失敗してもAuth側の成功を巻き込まない。
  Future<void> _syncUserDoc(String uid, String displayName) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      await _firestore.collection('users').doc(uid).set({
        'displayName': displayName,
        'updatedAt': Timestamp.now(),
        // 未設定のときだけデフォルト値を書き込む（既存の設定を上書きしない）
        if (data?['shareWantToGo'] == null) 'shareWantToGo': true,
        if (data?['shareVisited'] == null) 'shareVisited': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('users/$uid の同期に失敗しました: $e');
    }
  }

  @override
  Stream<AuthUser?> watchAuthState() {
    return _auth.userChanges().map((user) {
      if (user == null) return null;
      return AuthUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        emailVerified: user.emailVerified,
      );
    });
  }

  static String _generateTempPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(24, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Future<void> registerWithEmail(String email, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _generateTempPassword(),
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      final uid = credential.user?.uid;
      if (uid != null) await _syncUserDoc(uid, displayName);
      // パスワード設定リンクをメール送信（Firebase がメール確認も兼ねる）
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      final name = user?.displayName;
      if (user != null && name != null && name.isNotEmpty) {
        await _syncUserDoc(user.uid, name);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> setDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
      await _auth.currentUser?.reload();
      final uid = _auth.currentUser?.uid;
      if (uid != null) await _syncUserDoc(uid, name);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  @override
  Future<void> reloadCurrentUser() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }
}
