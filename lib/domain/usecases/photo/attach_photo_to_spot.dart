import 'package:tekushare/domain/repositories/photo_repository.dart';

class AttachPhotoToSpot {
  const AttachPhotoToSpot(this._repository);

  final PhotoRepository _repository;

  Future<void> call(String spotId, String imagePath) {
    return _repository.attachPhoto(spotId, imagePath);
  }
}
