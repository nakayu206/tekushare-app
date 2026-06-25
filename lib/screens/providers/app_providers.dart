import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/data/repositories/photo_repository_impl.dart';
import 'package:tekushare/data/repositories/route_repository_impl.dart';
import 'package:tekushare/data/repositories/spot_repository_impl.dart';
import 'package:tekushare/data/repositories/walk_session_repository_impl.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/infrastructure/notification_service.dart';

/// Isar インスタンスを非同期で提供する。
/// アプリ起動時に一度だけ初期化される。
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [SpotModelSchema, WalkSessionModelSchema, WalkRouteModelSchema],
    directory: dir.path,
  );
});

final spotRepositoryProvider = Provider<SpotRepository>((ref) {
  return SpotRepositoryImpl(ref.watch(isarProvider).requireValue);
});

final walkSessionRepositoryProvider = Provider<WalkSessionRepository>((ref) {
  return WalkSessionRepositoryImpl(ref.watch(isarProvider).requireValue);
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepositoryImpl(ref.watch(isarProvider).requireValue);
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(ref.watch(isarProvider).requireValue);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
