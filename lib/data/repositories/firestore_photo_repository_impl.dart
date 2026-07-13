import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';

class FirestorePhotoRepositoryImpl implements PhotoRepository {
  FirestorePhotoRepositoryImpl(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('spots');

  @override
  Future<void> attachPhoto(String spotId, String imagePath) async {
    await _collection.doc(spotId).update({
      'photoPaths': FieldValue.arrayUnion([imagePath]),
    });
  }

  @override
  Future<void> removePhoto(String spotId, String imagePath) async {
    await _collection.doc(spotId).update({
      'photoPaths': FieldValue.arrayRemove([imagePath]),
    });
  }
}
