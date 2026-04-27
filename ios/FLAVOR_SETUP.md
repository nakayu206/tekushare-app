# iOS Flavor セットアップ手順（Mac で実施）

> Windows 側では xcconfig 雛形と Info.plist の変数化までを実施済み。
> 残作業は Xcode 上での Build Configuration / Scheme の作成。

## 前提

- macOS + Xcode が必要
- 作業前に Git でコミットしておく（pbxproj が壊れた際の復旧用）

---

## 1. Xcode を開く

```bash
cd ios
open Runner.xcworkspace
```

> ⚠️ `Runner.xcodeproj` ではなく `.xcworkspace` を開くこと

---

## 2. Build Configuration を作成

`Runner` プロジェクト → `Info` タブ → `Configurations` セクションで、
既存の `Debug` / `Release` / `Profile` を flavor 数だけ複製する。

最終的に 9 つになる:

| Configuration |
|---|
| Debug-dev / Profile-dev / Release-dev |
| Debug-stg / Profile-stg / Release-stg |
| Debug-prod / Profile-prod / Release-prod |

複製手順:
1. `Debug` を選択 → 下部の `+` → `Duplicate "Debug" Configuration` → `Debug-dev` にリネーム
2. 同様に `Debug-stg`, `Debug-prod`, `Profile-*`, `Release-*` を作成
3. 元の `Debug` / `Release` / `Profile` は削除して構わない

---

## 3. xcconfig を Configuration に紐付ける

各 Configuration の `Based on Configuration File` 列で、`Runner` ターゲットに対して下記を選択する。

| Configuration | xcconfig（Runner ターゲット） |
|---|---|
| Debug-dev   | `Flutter/Debug` |
| Profile-dev | `Flutter/Profile` |
| Release-dev | `Flutter/Release` |
| Debug-stg   | `Flutter/Debug` |
| Profile-stg | `Flutter/Profile` |
| Release-stg | `Flutter/Release` |
| Debug-prod  | `Flutter/Debug` |
| Profile-prod| `Flutter/Profile` |
| Release-prod| `Flutter/Release` |

> Flutter 既存の `Debug.xcconfig` 等を継承する形。
> flavor 固有値（`BUNDLE_ID_SUFFIX` / `BUNDLE_DISPLAY_NAME`）は次のステップで include する。

---

## 4. flavor 用 xcconfig を include する

`ios/Flutter/Debug.xcconfig` などに条件付き include を追加する代わりに、
**Configuration ごとに別々の xcconfig を作る方が安全**。次の3ファイルを追加で用意する:

```
ios/Flutter/Debug-Dev.xcconfig
ios/Flutter/Debug-Stg.xcconfig
ios/Flutter/Debug-Prod.xcconfig
```

中身（Debug-Dev.xcconfig の例）:

```
#include "Debug.xcconfig"
#include "Dev.xcconfig"
```

同様に `Profile-Dev`, `Release-Dev`, `*-Stg`, `*-Prod` も作成（合計9ファイル）。
そして 3 で紐付けた xcconfig をこれらに差し替える。

---

## 5. Build Settings に変数を反映

`Runner` ターゲット → `Build Settings` で:

- **Product Bundle Identifier**: `com.example.tekushare$(BUNDLE_ID_SUFFIX)`
  - dev → `com.example.tekushare.dev`
  - stg → `com.example.tekushare.stg`
  - prod → `com.example.tekushare`

> `Build Settings` 上では1箇所変更すれば全 Configuration に反映される。

---

## 6. Scheme を作成

`Product` → `Scheme` → `Manage Schemes...` で 3 つの scheme を作る:

| Scheme 名 | Run | Test | Profile | Analyze | Archive |
|---|---|---|---|---|---|
| dev  | Debug-dev   | Debug-dev   | Profile-dev   | Debug-dev   | Release-dev   |
| stg  | Debug-stg   | Debug-stg   | Profile-stg   | Debug-stg   | Release-stg   |
| prod | Debug-prod  | Debug-prod  | Profile-prod  | Debug-prod  | Release-prod  |

各 Scheme は **Shared にチェック**（チームと共有するため）。

---

## 7. 動作確認

```bash
flutter run --flavor dev  -t lib/main_dev.dart
flutter run --flavor stg  -t lib/main_stg.dart
flutter run --flavor prod -t lib/main_prod.dart --release
```

ホーム画面に `TekuShare Dev` / `TekuShare Stg` / `TekuShare` の3つが並べてインストールできれば成功。

---

## トラブルシューティング

- **`Generated.xcconfig` が見つからない**: 一度 `flutter pub get` を実行
- **`The Flutter scheme has been deprecated` 警告**: 古い `Runner` scheme を削除
- **`PRODUCT_BUNDLE_IDENTIFIER` が反映されない**: Xcode を一度閉じて再度開く
