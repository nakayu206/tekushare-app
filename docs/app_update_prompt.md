# 起動時のアップデート案内

Firestore の `appUpdates/{flavor}_{platform}` を参照する。例は `prod_android`、`stg_android`、`dev_ios`。同一Firebaseプロジェクト内で案内の対象を分ける。

```json
{
  "latestBuild": 15,
  "minimumBuild": 13,
  "version": "1.0.2",
  "storeUrl": "https://play.google.com/store/apps/details?id=com.tekushare.app"
}
```

- `latestBuild`: ストアで配布済みの最新ビルド番号。現在のビルド番号がこれより小さいと案内する。
- `minimumBuild`: 利用可能な最小ビルド番号。これ未満は必須更新にし、「あとで」を表示しない。
- `version`: 案内に表示するバージョン名。
- `storeUrl`: Android は Google Play、iOS は実際の App Store の HTTPS URL を設定する。未確定のApp Store IDは登録しない。

通常更新は「あとで」を選ぶと、同じ最新ビルドに対して再表示しない。最低ビルドを引き上げた場合は既読でも必須更新を表示する。ストアから戻るなどフォアグラウンド復帰時にも再確認する。

設定未登録・不正な設定・ネットワーク障害時には起動を妨げない。表示済みの必須更新は一時的な取得失敗では解除しない。更新画面はサーバーのアクセス制御の代替にはならない。

## 有効化

1. この機能を含むアプリを配布し、ストアへの掲載と対象利用者への配信を確認する。
2. `firestore.rules` をデプロイする。設定ドキュメントはログイン前にも単一取得のみ許可し、クライアントからの一覧取得・変更は禁止する。
3. Firebase Consoleまたは管理者SDKから上記ドキュメントを作成する。公開前のビルドを最低ビルドに指定しない。

画面を実装していない旧バージョンには案内できない。今回の実装では本番設定の作成やデプロイは実施していない。
