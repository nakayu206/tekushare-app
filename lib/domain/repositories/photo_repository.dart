abstract interface class PhotoRepository {
  /// 写真を Storage にアップロードし、保存した URL を返す
  Future<String> attachPhoto(String spotId, String imagePath);
  Future<void> removePhoto(String spotId, String imagePath);
}
