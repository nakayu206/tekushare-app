import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tekushare/domain/repositories/walk_status_repository.dart';

class FirestoreWalkStatusRepositoryImpl implements WalkStatusRepository {
  const FirestoreWalkStatusRepositoryImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> setWalking() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set(
      {'walkingStatus': 'walking'},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> clearWalking() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update(
      {'walkingStatus': FieldValue.delete()},
    );
  }
}
