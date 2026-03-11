# sub-company — 専属子会社プラグイン for Claude Code

あなたを全力サポートする**専属の子会社**を設立し、AIと一緒に仕事を進める Claude Code プラグインです。

秘書があなたの依頼を受けて、各部署にサブエージェントとして命令を出し、並列で仕事を実行します。

> あなた → 秘書（子会社代表） → 命令 → 各専門部署（サブエージェント）

---

## インストール

```bash
# GitHub からインストール
claude plugin install kuruusuniku/sub-company

# ローカルフォルダからインストール
claude plugin install ./sub-company
```

---

## 組織構造

| 役職 | 役割 |
|------|------|
| **秘書（代表）** | 窓口・命令発行・TODO管理・報告 |
| **PM部** | プロジェクト管理・スケジュール・進捗確認 |
| **開発部** | 技術調査・コード・システム設計 |
| **マーケ部** | マーケティング戦略・コンテンツ・SNS |
| **営業部** | 提案書・台本・クライアント対応 |
| **経営企画部** | 戦略・競合分析・売上管理 |
| **品質管理部** | 全成果物をDevil's Advocateとしてレビュー |
| **CEO（召喚制）** | 大型タスクの戦略分析・夜間自律実行 |

---

## クイックスタート

```bash
# 1. 子会社を設立（初回のみ）
/company

# 2. 秘書に依頼する
/ask 来月のプロモーション戦略を立てたい

# 3. レポートを確認
/report weekly
```

---

## コマンド一覧

| コマンド | 説明 | 使用例 |
|----------|------|--------|
| `/company` | セットアップ・ダッシュボード表示 | `/company setup`, `/company dashboard` |
| `/company setup-github` | GitHub Issues連携のセットアップ | `/company setup-github` |
| `/company rename [名前]` | 秘書の名前を変更 | `/company rename みさき` |
| `/ask` | 秘書に相談・依頼 | `/ask 新機能のマーケ戦略を考えたい` |
| `/ask CEOを呼んで [依頼]` | CEO を召喚して戦略的に実行 | `/ask CEOを呼んで 事業計画を立てて` |
| `/ceo [タスク]` | CEO を直接召喚 | `/ceo 夜間モード`, `/ceo ステータス` |
| `/report` | 各部署からの進捗レポート生成 | `/report weekly`, `/report pm` |

---

## スキル（自動トリガー）

コマンドを使わなくても、自然言語で会社機能が起動します：

```
マーケ戦略を考えて
提案書を作って
技術調査をして
売上データをまとめて
この企画書のフィードバックをほしい
動画の台本を作りたい
SNS投稿文を書いて
```

---

## 実行モード

秘書は3つのモードで部署を動かせます（`config.md` で設定 or 口頭指示で切替）：

| モード | 動作 | 用途 |
|--------|------|------|
| `parallel` | 複数部署を同時にサブエージェントで実行（デフォルト） | 速度重視 |
| `sequential` | 1部署ずつ順番に実行 | トークン節約 |
| `inline` | サブエージェントなし、秘書が直接実行 | 最小消費 |

「節約モードで」「全力で」などの口頭指示でも即座に切り替わります。

---

## フォルダ構成

```
company/
├── dashboard.md          # 子会社ダッシュボード
├── secretary/
│   ├── config.md         # 秘書設定（名前・トーン・GitHub連携等）
│   ├── inbox.md          # 受信トレイ
│   └── todos.md          # 全社TODO
├── orders/               # 秘書が各部署へ出した命令ログ
├── pm/                   # PM部
│   └── orders/           # PM部への命令書・結果
├── dev/                  # 開発部
│   └── orders/
├── marketing/            # マーケ部
│   └── orders/
├── sales/                # 営業部
│   ├── proposals/
│   └── orders/
├── planning/             # 経営企画部
│   └── orders/
├── qa/                   # 品質管理部
│   ├── reviews/
│   └── orders/
├── ceo/                  # CEO（召喚時のみ使用）
│   ├── plans/
│   ├── reviews/
│   ├── reports/
│   └── orders/
└── reports/              # 自動生成レポート
```

---

## GitHub Issues 連携（オプション）

`/company setup-github` で GitHub Issues と連携すると、秘書がタスクを自動管理します：

- Issue の自動作成・ラベル付け
- カンバンボード（GitHub Projects）でステータス管理
- 完了時の自動クローズ

必要なもの：GitHub CLI (`gh`) がインストール済みであること。

---

## 動作要件

- Claude Code（`claude` コマンド）
- GitHub CLI（`gh`）— GitHub連携を使う場合のみ

---

## ライセンス

Apache License 2.0
