import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';

class FirestoreSpotRepositoryImpl implements SpotRepository {
  FirestoreSpotRepositoryImpl(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('spots');

  @override
  Future<void> saveSpot(Spot spot) async {
    await _collection.doc(spot.id).set(_toMap(spot));
  }

  @override
  Stream<List<Spot>> getSpots() {
    if (_uid.isEmpty) return Stream.value([]);
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs.map(_fromDoc).toList(),
        );
  }

  @override
  Future<void> updateSpotStatus(String id, SpotStatus status) async {
    await _collection.doc(id).update({'status': status.name});
  }

  @override
  Future<void> deleteSpot(String id) async {
    await _collection.doc(id).delete();
  }

  Map<String, dynamic> _toMap(Spot spot) => {
        'title': spot.title,
        'latitude': spot.latitude,
        'longitude': spot.longitude,
        'status': spot.status.name,
        'memo': spot.memo,
        'category': spot.category,
        'photoPaths': spot.photoPaths,
        'createdAt': Timestamp.fromDate(spot.createdAt),
      };

  Spot _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Spot(
      id: doc.id,
      title: data['title'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      status: SpotStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? ''),
        orElse: () => SpotStatus.wantToGo,
      ),
      memo: data['memo'] as String?,
      category: data['category'] as String?,
      photoPaths: (data['photoPaths'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
