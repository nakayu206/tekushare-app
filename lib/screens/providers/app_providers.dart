import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/data/models/saved_route_model.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/data/models/walk_session_model.dart';
import 'package:tekushare/data/repositories/route_repository_impl.dart';
import 'package:tekushare/data/repositories/saved_route_repository_impl.dart';
import 'package:tekushare/data/repositories/walk_session_repository_impl.dart';
import 'package:tekushare/domain/repositories/account_link_repository.dart';
import 'package:tekushare/domain/repositories/contact_repository.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/saved_route_repository.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/infrastructure/camera_service.dart';
import 'package:tekushare/infrastructure/sms_service.dart';
export 'package:tekushare/screens/providers/notification_provider.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// Isar インスタンスを非同期で提供する。
/// アプリ起動時に一度だけ初期化される。
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      WalkSessionModelSchema,
      WalkRouteModelSchema,
      SavedRouteModelSchema,
    ],
    directory: dir.path,
  );
  ref.onDispose(isar.close);
  return isar;
});

// 実装は firebase_providers.dart の firebaseProviderOverrides() で注入する。
final spotRepositoryProvider = Provider<SpotRepository>((ref) {
  throw UnimplementedError(
      'spotRepositoryProvider must be overridden in ProviderScope');
});

final walkSessionRepositoryProvider = Provider<WalkSessionRepository>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid ?? '';
  return WalkSessionRepositoryImpl(ref.watch(isarProvider).requireValue, uid);
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid ?? '';
  return RouteRepositoryImpl(ref.watch(isarProvider).requireValue, uid);
});

final savedRouteRepositoryProvider = Provider<SavedRouteRepository>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid ?? '';
  return SavedRouteRepositoryImpl(ref.watch(isarProvider).requireValue, uid);
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  throw UnimplementedError(
      'photoRepositoryProvider must be overridden in ProviderScope');
});

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  throw UnimplementedError(
      'contactRepositoryProvider must be overridden in ProviderScope');
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final smsServiceProvider = Provider<SmsService>((ref) {
  return const SmsServiceImpl();
});

final accountLinkRepositoryProvider = Provider<AccountLinkRepository>((ref) {
  throw UnimplementedError(
      'accountLinkRepositoryProvider must be overridden in ProviderScope');
});

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// DB・SharedPreferences 初期化完了を表すプロバイダー。
/// ウィジェットテストでは overrideWith(() async {}) で即時解決できる。
final appReadyProvider = FutureProvider<void>((ref) async {
  await Future.wait([
    ref.watch(isarProvider.future),
    ref.watch(sharedPrefsProvider.future),
  ]);
});
