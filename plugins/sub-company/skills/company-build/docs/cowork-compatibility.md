# Cowork互換性ガイド

## 概要

sub-companyプラグインはClaude Code CLI（ローカル）とCowork（チーム共有環境）の両方で動作する。
Cowork環境では一部の機能が利用できないため、自動検出して機能を制限（ナーフ）する。

## Cowork環境の検出方法

以下の手順でCowork環境かどうかを判定する：

1. `company/secretary/config.md` に `environment: cowork` が明示されている → Coworkモード
2. 明示されていない場合は、初回実行時に以下をチェック：
   - Bash ツールが利用不可 → Coworkモード
   - `allowed-tools` に Bash が含まれていない → Coworkモード
3. Coworkモードと判定した場合、`config.md` に `environment: cowork` を記録する

## Coworkモードで無効化される機能

| 機能 | 通常モード | Coworkモード | 理由 |
|------|-----------|-------------|------|
| GitHub Issues連携 | 有効 | **無効** | gh CLI前提、エンジニア向け機能 |
| launchd通知（リマインド） | 有効 | **無効** | macOSシェルスクリプト前提 |
| 開発パイプライン（E2E） | 有効 | **無効** | 外部ツール連携前提 |
| Agent spawn（parallel） | 有効 | **有効** | サブエージェントはCoworkでも動作する |
| Agent spawn（sequential） | 有効 | **有効** | 同上 |
| execution_mode 選択 | 全モード | **全モード** | parallel/sequential/inline すべて使用可 |
| Bash コマンド実行 | 有効 | **無効** | シェル非対応 |
| setup-github | 有効 | **非表示** | GitHub連携自体を無効化 |
| CEO夜間モード（スケジュール登録） | 有効 | **無効** | at/cron はBash前提 |
| CEO夜間モード（即時実行） | 有効 | **有効** | 「今すぐCEOに任せる」はAgent spawnで動作 |
| CEO「要確認」の記録先 | GitHub Issue | **inbox.md** | gh CLI不要にフォールバック |

## Coworkモードで有効な機能（ナーフ後も動くもの）

| 機能 | 動作 |
|------|------|
| `/ask` — 秘書への依頼 | 有効（全実行モード対応） |
| `/company setup` — 子会社設立 | 有効（GitHub案内をスキップ） |
| `/company dashboard` — ダッシュボード | 有効 |
| `/report` — レポート生成 | 有効（ファイル読み書きのみ） |
| 命令書の発行・保存 | 有効 |
| プレイブック（ナレッジ）参照・更新 | 有効 |
| 共有メモリ（3層メモリ） | 有効（markdownバックエンドのみ） |
| 品質管理部レビュー | 有効 |
| TODO管理 | 有効 |

## 各コマンドでの検出挿入箇所

### ask.md — ステップ0の直後に挿入

```markdown
## ステップ0.5：Cowork環境の検出

1. `company/secretary/config.md` を読み、`environment` フィールドを確認する
2. `environment: cowork` の場合 → Coworkモードで動作する：
   - GitHub Issue連携（ステップ5）をスキップする
   - GitHub未連携案内（ステップ7）を表示しない
   - launchd通知機能を無効化する
   - 開発パイプラインモード（ステップ2P）を無効化する
   - CEO夜間モードは即時実行（方法C）のみに制限する
   - Bashツールを使用しない
   - execution_mode は全モード使用可（Agent spawnはCoworkでも動作する）
3. `environment` フィールドがない場合 → 通常モードで動作する
```

### company.md — setup時のフロー修正

Coworkモードの場合：
- `setup-github` サブコマンドを非表示にする
- 設立完了メッセージから GitHub 連携の案内を省略する
- `config.md` に `environment: cowork` を初期値として設定する

## 設立時の config.md テンプレート（Cowork版）

```markdown
# 秘書設定

- **name**: [秘書名]
- **tone**: ていねい
- **mission**: [ユーザーの活動内容]
- **environment**: cowork
- **execution_mode**: parallel
- **memory_backend**: markdown
```

## 設立時の config.md テンプレート（通常版）

```markdown
# 秘書設定

- **name**: [秘書名]
- **tone**: ていねい
- **mission**: [ユーザーの活動内容]
- **environment**: local
- **execution_mode**: parallel
- **memory_backend**: markdown
```

## Coworkモード時の秘書の振る舞い

- 通常と同じ丁寧なトーンで対応する
- 「この機能はCowork版では利用できません」とは言わない（存在しないものとして扱う）
- execution_mode の切り替えは通常どおり応答する（parallel/sequential/inline すべて使用可）
- GitHub連携の提案は一切行わない
