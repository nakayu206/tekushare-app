import 'package:tekushare/domain/entities/linked_account.dart';

/// 招待リンクが存在しない、または既に使用済み・期限切れの場合
class InviteInvalidException implements Exception {
  const InviteInvalidException();
}

/// 自分自身の招待リンクを承認しようとした場合
class SelfInviteException implements Exception {
  const SelfInviteException();
}

/// 既に連携済みの相手を再度承認しようとした場合
class AlreadyLinkedException implements Exception {
  const AlreadyLinkedException();
}

abstract interface class AccountLinkRepository {
  /// 自分と連携済みのアカウント一覧をリアルタイム監視する
  Stream<List<LinkedAccount>> watchLinkedAccounts();

  /// 招待トークンを発行し、共有用URLを返す
  Future<String> createInviteLink();

  /// トークンから招待元の情報を取得する（承認画面の表示用）
  /// 無効・期限切れの場合は [InviteInvalidException] を投げる
  Future<InviteDetails> fetchInviteDetails(String token);

  /// 招待を承認し、双方を連携済みにする
  Future<void> acceptInvite(String token);

  /// 指定した相手との連携を解除する
  Future<void> unlink(String otherUid);
}
