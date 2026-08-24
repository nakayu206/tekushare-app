abstract interface class WalkStatusRepository {
  Future<void> setWalking();
  Future<void> clearWalking();
}
