# Android リリース手順チェックリスト

## 1. Firebase Console の更新

1. [Firebase Console](https://console.firebase.google.com/) を開く
2. プロジェクト設定 → 「アプリ」タブ
3. 既存の Android アプリ（`com.example.tekushare`）を削除
4. 新しい Android アプリを追加：
   - prod: `tekushare.app`
   - dev: `tekushare.app.dev`（任意）
   - stg: `tekushare.app.stg`（任意）
5. `google-services.json` をダウンロードし `android/app/google-services.json` に配置

## 2. リリース用キーストアの生成

```bash
keytool -genkey -v \
  -keystore tekushare-release.jks \
  -alias tekushare \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> キーストアファイルは**絶対に Git にコミットしない**こと。安全な場所に保管する。

## 3. key.properties の作成

`android/key.properties`（`.gitignore` で除外済み）を作成し、以下を記入：

```
storePassword=<キーストアのパスワード>
keyPassword=<キーのパスワード>
keyAlias=tekushare
storeFile=<キーストアファイルの絶対パス>
```

テンプレートは `android/key.properties.template` を参照。

## 4. App Links の SHA-256 更新

リリース署名の SHA-256 フィンガープリントを取得：

```bash
keytool -list -v \
  -keystore tekushare-release.jks \
  -alias tekushare
```

取得した SHA-256 を `public/.well-known/assetlinks.json` の `sha256_cert_fingerprints` に追加し、Firebase Hosting に再デプロイ：

```bash
firebase deploy --only hosting
```

## 5. リリースビルドの確認

```bash
flutter build apk --flavor prod --release
flutter build appbundle --flavor prod --release
```

## 6. Google Play Console への提出

1. [Google Play Console](https://play.google.com/console) でアプリを作成
2. Application ID: `tekushare.app`
3. `build/app/outputs/bundle/prodRelease/app-prod-release.aab` をアップロード

## 関連 Issue

- #124 Android リリース準備
- #120 iOS Universal Links Team ID 設定（Mac 作業が必要）
