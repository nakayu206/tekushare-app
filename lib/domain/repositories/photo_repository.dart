abstract interface class PhotoRepository {
  Future<void> attachPhoto(String spotId, String imagePath);
}
