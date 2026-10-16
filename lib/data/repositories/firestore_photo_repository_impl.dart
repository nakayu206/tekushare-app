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
    final storagePath = 'users/$_uid/spots/$spotId/$fileName';
    await _storage.ref(storagePath).putFile(File(imagePath));
    // 長期有効なダウンロードURLは発行・保存せず、Storageのパスを保存する
    // （表示時にログイン中のユーザー権限で取得するため、連携解除・共有OFFが即時反映される）
    await _collection.doc(spotId).set(
      {
        'photoPaths': FieldValue.arrayUnion([storagePath])
      },
      SetOptions(merge: true),
    );
    return storagePath;
  }

  @override
  Future<void> removePhoto(String spotId, String imagePath) async {
    await _collection.doc(spotId).set(
      {
        'photoPaths': FieldValue.arrayRemove([imagePath])
      },
      SetOptions(merge: true),
    );
    if (imagePath.startsWith('users/') || imagePath.startsWith('https://')) {
      try {
        final ref = imagePath.startsWith('users/')
            ? _storage.ref(imagePath)
            : _storage.refFromURL(imagePath);
        await ref.delete();
      } catch (_) {
        // Storage上に存在しない場合は無視
      }
    }
  }
}
