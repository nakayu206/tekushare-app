import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tekushare/data/models/saved_route_model.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/data/repositories/account_link_repository_impl.dart';
import 'package:tekushare/data/repositories/photo_repository_impl.dart';
import 'package:tekushare/data/repositories/route_repository_impl.dart';
import 'package:tekushare/data/repositories/saved_route_repository_impl.dart';
import 'package:tekushare/data/repositories/spot_repository_impl.dart';
import 'package:tekushare/data/repositories/walk_session_repository_impl.dart';
import 'package:tekushare/domain/repositories/account_link_repository.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/saved_route_repository.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/infrastructure/camera_service.dart';
import 'package:tekushare/infrastructure/notification_service.dart';

/// Isar インスタンスを非同期で提供する。
/// アプリ起動時に一度だけ初期化される。
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      SpotModelSchema,
      WalkSessionModelSchema,
      WalkRouteModelSchema,
      SavedRouteModelSchema,
    ],
    directory: dir.path,
  );
  ref.onDispose(isar.close);
  return isar;
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

final savedRouteRepositoryProvider = Provider<SavedRouteRepository>((ref) {
  return SavedRouteRepositoryImpl(ref.watch(isarProvider).requireValue);
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(ref.watch(isarProvider).requireValue);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final accountLinkRepositoryProvider = Provider<AccountLinkRepository>((ref) {
  return AccountLinkRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

/// DB 初期化完了を表すプロバイダー。
/// ウィジェットテストでは overrideWith(() async {}) で即時解決できる。
final appReadyProvider = FutureProvider<void>((ref) async {
  await ref.watch(isarProvider.future);
});
