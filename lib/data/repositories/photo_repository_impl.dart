import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';
import 'package:tekushare/objectbox.g.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  PhotoRepositoryImpl(Store store) : _box = store.box<SpotModel>();

  final Box<SpotModel> _box;

  @override
  Future<String> attachPhoto(String spotId, String imagePath) async {
    final model = _box.query(SpotModel_.uid.equals(spotId)).build().findFirst();
    if (model == null) throw StateError('Spot not found: $spotId');
    model.photoPaths = [...model.photoPaths, imagePath];
    _box.put(model);
    return imagePath;
  }

  @override
  Future<void> removePhoto(String spotId, String imagePath) async {
    final model = _box.query(SpotModel_.uid.equals(spotId)).build().findFirst();
    if (model == null) return;
    model.photoPaths = model.photoPaths.where((p) => p != imagePath).toList();
    _box.put(model);
  }
}
