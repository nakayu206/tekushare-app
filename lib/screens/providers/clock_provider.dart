import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1秒ごとに現在時刻を流すStreamProvider
/// autoDispose により画面を離れると自動でキャンセルされる
final clockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
