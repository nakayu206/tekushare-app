# 🚶 てくしぇあ（TekuShare）

> 散歩中に「ここいいな」を即記録、ルートも残るアプリ

毎日の散歩中に「この店いいな」「この公園また来たい」と感じた瞬間を、1タップで記録できるモバイルアプリ。散歩のルートも自動で保存され、行きたい場所・行った場所を地図とリストで管理できます。

---

## ✨ 主要機能

| 機能                    | 概要                                          |
| ----------------------- | --------------------------------------------- |
| 📍 行きたいボタン       | 散歩中の現在地を1タップで即保存               |
| ✅ ステータス管理       | 「行きたい」→「行った」で達成感を可視化       |
| ⏱ 散歩タイマー          | 15分で折返し通知。往復30分が自動完結          |
| 🗺 ルート可視化         | GPSで歩いた道を地図に記録                     |
| 📷 写真をマップに紐づけ | 撮影 / カメラロールから写真をスポットに追加   |
| 👥 家族・友人とのシェア | スポットリストを共有（Phase2）                |
| 🆘 安否確認             | 一定時間 GPS が停止したら家族に通知（Phase2） |

詳細：[docs/全体設計書.md](docs/%E5%85%A8%E4%BD%93%E8%A8%AD%E8%A8%88%E6%9B%B8.md)

---

## 🛠 技術スタック

| 用途            | 採用                                         |
| --------------- | -------------------------------------------- |
| フレームワーク  | Flutter / Dart                               |
| 対応 OS         | iOS / Android                                |
| 状態管理        | Riverpod                                     |
| 位置情報        | geolocator                                   |
| 地図表示        | flutter_map + OpenStreetMap                  |
| ローカル DB     | Isar                                         |
| 通知            | flutter_local_notifications                  |
| 写真選択・撮影  | image_picker                                 |
| Phase2 クラウド | Firebase（Auth / Firestore / FCM / Storage） |

---

## 📂 ディレクトリ構成

```
lib/
  main.dart           # 共通エントリ
  main_dev.dart       # dev flavor
  main_stg.dart       # stg flavor
  main_prod.dart      # prod flavor
  app.dart
  core/               # 共通基盤
  data/               # データソース・モデル
  domain/             # ドメインロジック
  infrastructure/     # 外部サービス連携
  presentation/       # UI / 画面 / Widget
docs/                 # 設計・運用ドキュメント
.github/workflows/    # CI/CD（GitHub Actions）
```

---

## 🚀 セットアップ

詳細手順：[docs/環境構築手順.md](docs/%E7%92%B0%E5%A2%83%E6%A7%8B%E7%AF%89%E6%89%8B%E9%A0%86.md)

### 必要環境

| 項目           | バージョン                  |
| -------------- | --------------------------- |
| Flutter        | 3.41.x 以上                 |
| Dart           | 3.11.x 以上（Flutter 同梱） |
| Android Studio | 最新安定版                  |
| Xcode          | 最新安定版（macOS のみ）    |

### クイックスタート

```bash
# 依存パッケージ取得
flutter pub get

# 開発環境（dev flavor）で起動
flutter run --flavor dev -t lib/main_dev.dart
```

---

## 🌱 環境（Flavor）

| Flavor | 用途        | 起動コマンド                                      |
| ------ | ----------- | ------------------------------------------------- |
| dev    | 開発用      | `flutter run --flavor dev -t lib/main_dev.dart`   |
| stg    | 検証・QA 用 | `flutter run --flavor stg -t lib/main_stg.dart`   |
| prod   | 本番        | `flutter run --flavor prod -t lib/main_prod.dart` |

詳細：[docs/環境とブランチ運用.md](docs/%E7%92%B0%E5%A2%83%E3%81%A8%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E9%81%8B%E7%94%A8.md)

---

## 🔁 開発フロー

```
feature/xxx で開発
   ↓ push
PR 作成
   ↓
CI（format / analyze / test）自動実行
   ↓ 通過
main にマージ → stg ビルド自動生成
   ↓
git tag v1.0.0 → prod ビルド自動生成
```

- ブランチ戦略：GitHub Flow（main 1本 + feature/\* 短命ブランチ）
- 環境出し分け：Flavor + GitHub Actions
- 詳細：[docs/環境とブランチ運用.md](docs/%E7%92%B0%E5%A2%83%E3%81%A8%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E9%81%8B%E7%94%A8.md)

---

## 📚 ドキュメント

| ドキュメント                                                                                                    | 内容                                           |
| --------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| [全体設計書](docs/%E5%85%A8%E4%BD%93%E8%A8%AD%E8%A8%88%E6%9B%B8.md)                                             | コンセプト・機能・画面・状態管理・ファイル構造 |
| [コード規約](docs/%E3%82%B3%E3%83%BC%E3%83%89%E8%A6%8F%E7%B4%84.md)                                             | 命名・責務・コメント・Riverpod 使い方          |
| [デザイントークン](docs/%E3%83%87%E3%82%B6%E3%82%A4%E3%83%B3%E3%83%88%E3%83%BC%E3%82%AF%E3%83%B3.md)            | 色・タイポグラフィ・スペーシング               |
| [環境構築手順](docs/%E7%92%B0%E5%A2%83%E6%A7%8B%E7%AF%89%E6%89%8B%E9%A0%86.md)                                  | 新規 PC・新メンバー向けセットアップ            |
| [環境とブランチ運用](docs/%E7%92%B0%E5%A2%83%E3%81%A8%E3%83%96%E3%83%A9%E3%83%B3%E3%83%81%E9%81%8B%E7%94%A8.md) | dev/stg/prod、ブランチ戦略、CI/CD              |
| [iOS Flavor セットアップ](ios/FLAVOR_SETUP.md)                                                                  | iOS 側の Flavor 設定                           |
| [GitHub Actions](.github/workflows/README.md)                                                                   | CI/CD ワークフロー詳細                         |

---

## 🗺 開発ロードマップ

- **Phase 1（MVP）**: タイマー / GPS ルート記録 / スポット保存 / 写真 / 安否確認（本人通知）
- **Phase 2（シェア）**: Firebase Auth / Firestore / 家族通知（FCM） / 写真クラウド保存
- **Phase 3（リリース）**: App Store / Google Play 申請・審査

---

## 📄 ライセンス

[LICENSE](LICENSE) を参照してください。
