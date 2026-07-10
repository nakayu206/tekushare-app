import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/linked_account.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

/// 自分と連携済みのアカウント一覧
final linkedAccountsProvider = StreamProvider<List<LinkedAccount>>((ref) {
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
