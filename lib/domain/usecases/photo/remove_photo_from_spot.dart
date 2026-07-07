import 'package:tekushare/domain/repositories/photo_repository.dart';

class RemovePhotoFromSpot {
  const RemovePhotoFromSpot(this._repository);

  final PhotoRepository _repository;

  Future<void> call(String spotId, String imagePath) =>
      _repository.removePhoto(spotId, imagePath);
}
