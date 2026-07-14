import 'package:isar/isar.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  PhotoRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<String> attachPhoto(String spotId, String imagePath) async {
    await _isar.writeTxn(() async {
      final model = await _isar.spotModels.getByUid(spotId);
      if (model == null) return;
      model.photoPaths = [...model.photoPaths, imagePath];
      await _isar.spotModels.put(model);
    });
    return imagePath;
  }

  @override
  Future<void> removePhoto(String spotId, String imagePath) async {
    await _isar.writeTxn(() async {
      final model = await _isar.spotModels.getByUid(spotId);
      if (model == null) return;
      model.photoPaths = model.photoPaths.where((p) => p != imagePath).toList();
      await _isar.spotModels.put(model);
    });
  }
}
