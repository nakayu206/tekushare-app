import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tekushare/domain/entities/contact.dart';
import 'package:tekushare/domain/repositories/contact_repository.dart';

class FirestoreContactRepositoryImpl implements ContactRepository {
  FirestoreContactRepositoryImpl(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('contacts');

  @override
  Stream<List<Contact>> watchContacts() {
    if (_uid.isEmpty) return const Stream.empty();
    return _collection.snapshots().map(
          (snap) => snap.docs
              .map(
                (doc) => Contact(
                  id: doc.id,
                  name: doc.data()['name'] as String,
                  phone: doc.data()['phone'] as String,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> saveContact(Contact contact) async {
    final data = {'name': contact.name, 'phone': contact.phone};
    if (contact.id.isEmpty) {
      await _collection.add(data);
    } else {
      await _collection.doc(contact.id).set(data);
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    await _collection.doc(id).delete();
  }
}
