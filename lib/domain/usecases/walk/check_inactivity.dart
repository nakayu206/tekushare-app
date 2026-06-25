class CheckInactivity {
  const CheckInactivity();

  static const _threshold = Duration(minutes: 10);

  bool call(DateTime lastActionAt) {
    return DateTime.now().difference(lastActionAt) > _threshold;
  }
}
