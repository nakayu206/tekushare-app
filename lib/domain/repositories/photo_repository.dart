abstract interface class PhotoRepository {
  Future<void> attachPhoto(String spotId, String imagePath);
  Future<void> removePhoto(String spotId, String imagePath);
}
