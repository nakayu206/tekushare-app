import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tekushare/domain/entities/linked_account.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/account_link_repository.dart';

const _inviteValidDuration = Duration(days: 7);

/// 2人のUIDから決定的な連携ドキュメントIDを作る（順序に依存しない）
String _linkIdOf(String uidA, String uidB) {
  final sorted = [uidA, uidB]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

/// 共有設定の更新と連携作成が重なった場合に、取り直して更新する最大回数
const _shareSyncMaxAttempts = 3;

/// users/{uid} の共有設定から、連携に持たせる共有設定を作る（未設定はデフォルトON）
Map<String, bool> _shareOf(Map<String, dynamic>? user) => {
      'wantToGo': user?['shareWantToGo'] as bool? ?? true,
      'visited': user?['shareVisited'] as bool? ?? true,
    };

class AccountLinkRepositoryImpl implements AccountLinkRepository {
  AccountLinkRepositoryImpl(
    this._firestore,
    this._auth, {
    @visibleForTesting this.afterShareBatchForTest,
  });

  /// テスト用: 共有設定のバッチ確定直後に呼ばれる（連携作成との競合を再現するため）
  final Future<void> Function()? afterShareBatchForTest;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _myUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('ログインしていません');
    return uid;
  }

  @override
  Stream<List<LinkedAccount>> watchLinkedAccounts() {
    final myUid = _myUid;
    return _firestore
        .collection('accountLinks')
        .where('uids', arrayContains: myUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final accounts = <LinkedAccount>[];
      for (final doc in snapshot.docs) {
        final uids = List<String>.from(doc['uids'] as List);
        final otherUid = uids.firstWhere((u) => u != myUid);
        final userDoc =
            await _firestore.collection('users').doc(otherUid).get();
        final displayName = userDoc.data()?['displayName'] as String? ?? '';
        final createdAt = doc['createdAt'] as Timestamp?;
        accounts.add(LinkedAccount(
          uid: otherUid,
          displayName: displayName,
          linkedAt: createdAt?.toDate() ?? DateTime.now(),
        ));
      }
      return accounts;
    });
  }

  @override
  Future<String> createInviteLink() async {
    final myUid = _myUid;
    final ref = _firestore.collection('linkInvites').doc();
    final now = DateTime.now();
    await ref.set({
      'fromUid': myUid,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(_inviteValidDuration)),
      'used': false,
    });
    return 'https://tekushare.web.app/link/${ref.id}';
  }

  @override
  Future<InviteDetails> fetchInviteDetails(String token) async {
    final doc = await _firestore.collection('linkInvites').doc(token).get();
    final data = doc.data();
    if (data == null) throw const InviteInvalidException();

    final used = data['used'] as bool? ?? true;
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    if (used || expiresAt == null || expiresAt.isBefore(DateTime.now())) {
      throw const InviteInvalidException();
    }

    final fromUidRaw = data['fromUid'];
    if (fromUidRaw is! String) throw const InviteInvalidException();
    final fromUid = fromUidRaw;
    final userDoc = await _firestore.collection('users').doc(fromUid).get();
    final displayName = userDoc.data()?['displayName'] as String? ?? '';
    return InviteDetails(fromUid: fromUid, fromDisplayName: displayName);
  }

  @override
  Future<void> acceptInvite(String token) async {
    final myUid = _myUid;
    final inviteRef = _firestore.collection('linkInvites').doc(token);

    await _firestore.runTransaction((tx) async {
      final inviteSnap = await tx.get(inviteRef);
      final data = inviteSnap.data();
      if (data == null) throw const InviteInvalidException();

      final used = data['used'] as bool? ?? true;
      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
      if (used || expiresAt == null || expiresAt.isBefore(DateTime.now())) {
        throw const InviteInvalidException();
      }

      final fromUidRaw = data['fromUid'];
      if (fromUidRaw is! String) throw const InviteInvalidException();
      final fromUid = fromUidRaw;
      if (fromUid == myUid) throw const SelfInviteException();

      final linkId = _linkIdOf(fromUid, myUid);
      final linkRef = _firestore.collection('accountLinks').doc(linkId);
      final linkSnap = await tx.get(linkRef);
      if (linkSnap.exists) throw const AlreadyLinkedException();

      // 各ユーザーの共有設定を連携に持たせる（Storageルールが写真の公開可否に使う）
      final fromUserSnap =
          await tx.get(_firestore.collection('users').doc(fromUid));
      final myUserSnap =
          await tx.get(_firestore.collection('users').doc(myUid));

      tx.set(linkRef, {
        'uids': [fromUid, myUid],
        'shares': {
          fromUid: _shareOf(fromUserSnap.data()),
          myUid: _shareOf(myUserSnap.data()),
        },
        'createdAt': Timestamp.now(),
        // Firestoreルールが「正当な招待経由か」を検証するために必要
        'inviteToken': token,
      });
      tx.update(inviteRef, {'used': true});
    });
  }

  @override
  Future<void> unlink(String otherUid) async {
    final linkId = _linkIdOf(_myUid, otherUid);
    await _firestore.collection('accountLinks').doc(linkId).delete();
  }

  @override
  Future<void> updateShareSettings({
    required bool shareWantToGo,
    required bool shareVisited,
  }) async {
    final myUid = _myUid;
    final desired = {'wantToGo': shareWantToGo, 'visited': shareVisited};
    var settingsWritten = false;
    for (var attempt = 0; attempt < _shareSyncMaxAttempts; attempt++) {
      final links = await _firestore
          .collection('accountLinks')
          .where('uids', arrayContains: myUid)
          .get();
      final stale = links.docs.where((link) {
        final mine = (link.data()['shares'] as Map?)?[myUid] as Map?;
        return mine?['wantToGo'] != shareWantToGo ||
            mine?['visited'] != shareVisited;
      }).toList();
      // 設定を書いた後に、古い設定のまま残った連携が無ければ完了
      if (settingsWritten && stale.isEmpty) return;

      // 設定と、各連携の共有設定(shares.{自分})を1回のバッチで原子的に更新する。
      // 連携は少数なので分割は不要。更新途中に写真が公開されたままになることはない。
      final batch = _firestore.batch();
      batch.set(
        _firestore.collection('users').doc(myUid),
        {'shareWantToGo': shareWantToGo, 'shareVisited': shareVisited},
        SetOptions(merge: true),
      );
      for (final link in stale) {
        batch.update(link.reference, {'shares.$myUid': desired});
      }
      await batch.commit();
      settingsWritten = true;
      await afterShareBatchForTest?.call();
      // 連携の一覧取得から確定までの間に別の連携が作られた場合は、
      // 次の周回で検出して更新する（確定後の新規連携はルールが設定との一致を要求する）
    }
  }

  @override
  Future<({bool shareWantToGo, bool shareVisited})> fetchShareSettings(
      String otherUid) async {
    final doc = await _firestore.collection('users').doc(otherUid).get();
    final data = doc.data() ?? {};
    return (
      shareWantToGo: data['shareWantToGo'] as bool? ?? true,
      shareVisited: data['shareVisited'] as bool? ?? true,
    );
  }

  @override
  Future<List<Spot>> fetchSharedSpots(
    String otherUid, {
    required bool shareWantToGo,
    required bool shareVisited,
  }) async {
    final statuses = [
      if (shareWantToGo) SpotStatus.wantToGo.name,
      if (shareVisited) SpotStatus.visited.name,
    ];
    // セキュリティルールはクエリが status で絞られていることを要求するため、
    // ステータスごとに個別に取得する
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final status in statuses) {
      final snap = await _firestore
          .collection('users')
          .doc(otherUid)
          .collection('spots')
          .where('status', isEqualTo: status)
          .get();
      docs.addAll(snap.docs);
    }
    return docs.map((doc) {
      final d = doc.data();
      return Spot(
        id: doc.id,
        title: d['title'] as String? ?? '',
        latitude: (d['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (d['longitude'] as num?)?.toDouble() ?? 0.0,
        status: SpotStatus.values.firstWhere(
          (s) => s.name == (d['status'] as String? ?? ''),
          orElse: () => SpotStatus.wantToGo,
        ),
        memo: d['memo'] as String?,
        category: d['category'] as String?,
        photoPaths: (d['photoPaths'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }
}
