import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/linked_account.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';

/// 自分と連携済みのアカウント一覧
///
/// authStateProvider を watch することで、ログアウト・別アカウントでのログイン時に
/// 自動的に再購読し、前ユーザーのデータが残らないようにする。
final linkedAccountsProvider = StreamProvider<List<LinkedAccount>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(accountLinkRepositoryProvider).watchLinkedAccounts();
});

/// 招待トークンから招待元の情報を取得する（承認画面用）
final inviteDetailsProvider =
    FutureProvider.family<InviteDetails, String>((ref, token) {
  return ref.watch(accountLinkRepositoryProvider).fetchInviteDetails(token);
});

/// ログイン前にディープリンクを開いた場合に、ログイン完了後まで
/// トークンを一時保持しておくためのプロバイダー
final pendingInviteTokenProvider = StateProvider<String?>((ref) => null);
