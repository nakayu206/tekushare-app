import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tekushare/domain/entities/contact.dart';
import 'package:tekushare/domain/repositories/contact_repository.dart';

class FirestoreContactRepositoryImpl implements ContactRepository {
  FirestoreContactRepositoryImpl(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  DocumentReference<Map<String, dynamic>> get _doc => _firestore
      .collection('users')
      .doc(_uid)
      .collection('settings')
      .doc('contact');

  @override
  Stream<Contact?> watchContact() {
    if (_uid.isEmpty) return const Stream.empty();
    return _doc.snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return Contact(
        name: data['name'] as String,
        phone: data['phone'] as String,
      );
    });
  }

  @override
  Future<void> saveContact(Contact contact) async {
    await _doc.set({'name': contact.name, 'phone': contact.phone});
  }

  @override
  Future<void> deleteContact() async {
    await _doc.delete();
  }
}
