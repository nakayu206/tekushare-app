/// 連携済みアカウント（相手ユーザー）
class LinkedAccount {
  const LinkedAccount({
    required this.uid,
    required this.displayName,
    required this.linkedAt,
  });

  final String uid;
  final String displayName;
  final DateTime linkedAt;
}

/// 招待リンクの発行元情報（承認画面での表示用）
class InviteDetails {
  const InviteDetails({
    required this.fromUid,
    required this.fromDisplayName,
  });

  final String fromUid;
  final String fromDisplayName;
}
