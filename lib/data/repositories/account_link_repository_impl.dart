import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tekushare/domain/entities/linked_account.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/account_link_repository.dart';

const _inviteValidDuration = Duration(days: 7);

/// 2人のUIDから決定的な連携ドキュメントIDを作る（順序に依存しない）
String _linkIdOf(String uidA, String uidB) {
  final sorted = [uidA, uidB]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

class AccountLinkRepositoryImpl implements AccountLinkRepository {
  AccountLinkRepositoryImpl(this._firestore, this._auth);

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

      tx.set(linkRef, {
        'uids': [fromUid, myUid],
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
    await _firestore.collection('users').doc(_myUid).set({
      'shareWantToGo': shareWantToGo,
      'shareVisited': shareVisited,
    }, SetOptions(merge: true));
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
    final snap = await _firestore
        .collection('users')
        .doc(otherUid)
        .collection('spots')
        .where('status', whereIn: statuses)
        .get();
    return snap.docs.map((doc) {
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
