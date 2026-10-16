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
    test('https://tekushare.web.app/link/ 形式のURLを返し、Firestoreにドキュメントを作る',
        () async {
      final repo = repoFor('uidA');
      final link = await repo.createInviteLink();

      expect(link, startsWith('https://tekushare.web.app/link/'));

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

    test('承認すると双方の共有設定が shares に入る（未設定はON）', () async {
      await firestore
          .collection('users')
          .doc('uidA')
          .set({'displayName': 'あかり', 'shareVisited': false});
      final link = await repoFor('uidA').createInviteLink();
      final token = link.split('/').last;

      await repoFor('uidB').acceptInvite(token);

      final shares =
          (await firestore.collection('accountLinks').doc('uidA_uidB').get())
              .data()!['shares'] as Map<String, dynamic>;
      expect(shares['uidA'], {'wantToGo': true, 'visited': false});
      expect(shares['uidB'], {'wantToGo': true, 'visited': true});
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

  group('updateShareSettings', () {
    test('設定と全連携の shares.自分 を同時に更新し、相手の分は変えない', () async {
      await putUser('uidA', 'あかり');
      await putUser('uidB', 'ぼぶ');
      await putUser('uidC', 'しー');
      for (final other in ['uidB', 'uidC']) {
        final token =
            (await repoFor('uidA').createInviteLink()).split('/').last;
        await repoFor(other).acceptInvite(token);
      }

      await repoFor('uidA')
          .updateShareSettings(shareWantToGo: false, shareVisited: true);

      final user = await firestore.collection('users').doc('uidA').get();
      expect(user.data()!['shareWantToGo'], false);
      for (final id in ['uidA_uidB', 'uidA_uidC']) {
        final shares =
            (await firestore.collection('accountLinks').doc(id).get())
                .data()!['shares'] as Map<String, dynamic>;
        expect(shares['uidA'], {'wantToGo': false, 'visited': true});
        expect(shares.keys.length, 2);
      }
      final other =
          (await firestore.collection('accountLinks').doc('uidA_uidB').get())
              .data()!['shares'] as Map<String, dynamic>;
      expect(other['uidB'], {'wantToGo': true, 'visited': true});
    });

    test('更新中に別の連携が作られても、取り直して非公開に更新する', () async {
      await putUser('uidA', 'あかり');
      // 一覧取得の後・確定の前に、変更前(ON)の設定で連携が作られた状況を再現する
      var created = false;
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uidA', displayName: 'uidA'),
      );
      final repo = AccountLinkRepositoryImpl(
        firestore,
        auth,
        afterShareBatchForTest: () async {
          if (created) return;
          created = true;
          await firestore.collection('accountLinks').doc('uidA_uidD').set({
            'uids': ['uidA', 'uidD'],
            'shares': {
              'uidA': {'wantToGo': true, 'visited': true},
              'uidD': {'wantToGo': true, 'visited': true},
            },
          });
        },
      );

      await repo.updateShareSettings(shareWantToGo: false, shareVisited: false);

      final shares =
          (await firestore.collection('accountLinks').doc('uidA_uidD').get())
              .data()!['shares'] as Map<String, dynamic>;
      expect(shares['uidA'], {'wantToGo': false, 'visited': false});
      expect(shares['uidD'], {'wantToGo': true, 'visited': true});
    });
  });
}
