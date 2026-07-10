import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/data/repositories/account_link_repository_impl.dart';
import 'package:tekushare/domain/repositories/account_link_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  AccountLinkRepositoryImpl repoFor(String uid, {String? displayName}) {
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid, displayName: displayName ?? uid),
    );
    return AccountLinkRepositoryImpl(firestore, auth);
  }

  Future<void> putUser(String uid, String displayName) {
    return firestore
        .collection('users')
        .doc(uid)
        .set({'displayName': displayName});
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('createInviteLink', () {
    test('tekushare://link/ 形式のURLを返し、Firestoreにドキュメントを作る', () async {
      final repo = repoFor('uidA');
      final link = await repo.createInviteLink();

      expect(link, startsWith('tekushare://link/'));

      final token = link.split('/').last;
      final doc = await firestore.collection('linkInvites').doc(token).get();
      expect(doc.exists, true);
      expect(doc.data()!['fromUid'], 'uidA');
      expect(doc.data()!['used'], false);
    });
  });

  group('fetchInviteDetails', () {
    test('有効な招待から招待元の表示名を取得できる', () async {
      await putUser('uidA', 'あかり');
      final link = await repoFor('uidA').createInviteLink();
      final token = link.split('/').last;

      final details = await repoFor('uidB').fetchInviteDetails(token);

      expect(details.fromUid, 'uidA');
      expect(details.fromDisplayName, 'あかり');
    });

    test('存在しないトークンは InviteInvalidException', () async {
      expect(
        () => repoFor('uidB').fetchInviteDetails('no-such-token'),
        throwsA(isA<InviteInvalidException>()),
      );
    });

    test('使用済みの招待は InviteInvalidException', () async {
      await putUser('uidA', 'あかり');
      final link = await repoFor('uidA').createInviteLink();
      final token = link.split('/').last;
      await repoFor('uidB').acceptInvite(token);

      expect(
        () => repoFor('uidC').fetchInviteDetails(token),
        throwsA(isA<InviteInvalidException>()),
      );
    });
  });

  group('acceptInvite', () {
    test('承認すると accountLinks に双方のuidを含むドキュメントができる', () async {
      await putUser('uidA', 'あかり');
      final link = await repoFor('uidA').createInviteLink();
      final token = link.split('/').last;

      await repoFor('uidB').acceptInvite(token);

      final linkDoc =
          await firestore.collection('accountLinks').doc('uidA_uidB').get();
      expect(linkDoc.exists, true);
      expect(List<String>.from(linkDoc.data()!['uids'] as List),
          containsAll(['uidA', 'uidB']));
    });

    test('承認後は招待が used になる', () async {
      final link = await repoFor('uidA').createInviteLink();
      final token = link.split('/').last;

      await repoFor('uidB').acceptInvite(token);

      final invite = await firestore.collection('linkInvites').doc(token).get();
      expect(invite.data()!['used'], true);
    });

    test('自分自身の招待は SelfInviteException', () async {
      final link = await repoFor('uidA').createInviteLink();
      final token = link.split('/').last;

      expect(
        () => repoFor('uidA').acceptInvite(token),
        throwsA(isA<SelfInviteException>()),
      );
    });

    test('既に連携済みなら AlreadyLinkedException', () async {
      final link1 = await repoFor('uidA').createInviteLink();
      await repoFor('uidB').acceptInvite(link1.split('/').last);

      final link2 = await repoFor('uidA').createInviteLink();
      expect(
        () => repoFor('uidB').acceptInvite(link2.split('/').last),
        throwsA(isA<AlreadyLinkedException>()),
      );
    });

    test('存在しないトークンは InviteInvalidException', () async {
      expect(
        () => repoFor('uidB').acceptInvite('no-such-token'),
        throwsA(isA<InviteInvalidException>()),
      );
    });
  });

  group('unlink / watchLinkedAccounts', () {
    test('承認後に相手が一覧に現れ、解除すると消える', () async {
      await putUser('uidA', 'あかり');
      await putUser('uidB', 'たかし');
      final link = await repoFor('uidA').createInviteLink();
      await repoFor('uidB').acceptInvite(link.split('/').last);

      final accountsForA = await repoFor('uidA').watchLinkedAccounts().first;
      expect(accountsForA, hasLength(1));
      expect(accountsForA.first.uid, 'uidB');
      expect(accountsForA.first.displayName, 'たかし');

      await repoFor('uidA').unlink('uidB');

      final linkDoc =
          await firestore.collection('accountLinks').doc('uidA_uidB').get();
      expect(linkDoc.exists, false);
    });
  });
}
