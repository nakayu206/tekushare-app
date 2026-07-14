import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';

class FirestorePhotoRepositoryImpl implements PhotoRepository {
  FirestorePhotoRepositoryImpl(this._firestore, this._storage, this._uid);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('spots');

  @override
  Future<String> attachPhoto(String spotId, String imagePath) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';
    final ref = _storage.ref('users/$_uid/spots/$spotId/$fileName');
    await ref.putFile(File(imagePath));
    final url = await ref.getDownloadURL();
    await _collection.doc(spotId).update({
      'photoPaths': FieldValue.arrayUnion([url]),
    });
    return url;
  }

  @override
  Future<void> removePhoto(String spotId, String imagePath) async {
    await _collection.doc(spotId).update({
      'photoPaths': FieldValue.arrayRemove([imagePath]),
    });
    if (imagePath.startsWith('https://')) {
      try {
        await _storage.refFromURL(imagePath).delete();
      } catch (_) {
        // Storage上に存在しない場合は無視
      }
    }
  }
}
