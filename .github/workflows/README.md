# GitHub Actions（CI/CD）ワークフロー

このフォルダには、GitHub Actions の自動化レシピ（ワークフロー）を配置しています。

## ファイル構成

| ファイル          | トリガー                | 用途                                                   |
| ----------------- | ----------------------- | ------------------------------------------------------ |
| `ci.yml`          | PR 作成・main への push | フォーマット / 静的解析 / テストを自動実行             |
| `deploy-stg.yml`  | main への push          | stg flavor で Android APK をビルド                     |
| `deploy-prod.yml` | `v*.*.*` タグの push    | prod flavor で App Bundle ビルド + GitHub Release 作成 |

## 運用フロー

```
1. feature ブランチで開発
   └─ PR 作成 → ci.yml が自動で test/analyze 実行
        └─ OK ならレビュー → main にマージ

2. main にマージされたら
   └─ deploy-stg.yml が stg ビルドを自動生成
        └─ Actions の Artifacts から APK をダウンロード可能

3. リリースしたいときは
   git tag v1.0.0
   git push origin v1.0.0
   └─ deploy-prod.yml が prod ビルドを自動生成
        └─ GitHub Releases にも自動投稿
```

## 配信（Firebase / Google Play）を有効化する手順

各 yml の末尾にコメントアウトされているステップを有効化してください。
事前に GitHub リポジトリの **Settings → Secrets and variables → Actions** で、
以下のシークレットを登録する必要があります。

### stg（Firebase App Distribution）

- `FIREBASE_APP_ID_STG`
- `FIREBASE_CREDENTIALS`（サービスアカウント JSON の中身）

### prod（Google Play）

- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

## 補足

- iOS のビルドは `runs-on: macos-latest` が必要で、署名証明書の取り扱いも別途必要なため、
  まずは Android 側のみ用意しています。必要になり次第追加してください。
- 詳しい考え方は [`docs/環境とブランチ運用.md`](../../docs/環境とブランチ運用.md) を参照。
