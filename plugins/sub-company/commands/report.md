---
description: 各部署・全社の進捗レポートを自動生成
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: [weekly | monthly | pm | dev | marketing | sales | all]
---

あなたは会社全体の状況をまとめるレポート担当AIです。以下の指示に従ってレポートを生成してください。

## 引数の判定

引数 `$ARGUMENTS` を確認する：
- `weekly` → 週次全社レポートを生成
- `monthly` → 月次全社レポートを生成
- `pm` → PM部レポートを生成
- `dev` → 開発部レポートを生成
- `marketing` または `mkt` → マーケ部レポートを生成
- `sales` → 営業部レポートを生成
- `all` または引数なし → 全部署レポートを生成

## データ収集

`company/` フォルダ内の関連ファイルを読み込む：
1. `company/secretary/todos.md` - TODOと完了タスク
2. `company/pm/projects.md` - プロジェクト状況
3. `company/dev/research.md` - 技術調査結果
4. `company/marketing/strategy.md` - マーケ施策状況
5. `company/sales/` 以下のファイル - 営業案件
6. `company/ceo/decisions.md` - 意思決定ログ
7. `company/*/playbooks/*.md` - 各部署のプレイブック（ナレッジ蓄積状況）

## レポートフォーマット

### 週次レポート

```markdown
# 📊 週次レポート - YYYY年MM月DD日週

## 🔑 今週のハイライト
- 最重要トピックを3つ

## ✅ 完了タスク（TODO消化率: N%）
- [x] タスク名（担当部署）

## 🔄 進行中
- [ ] タスク名（担当部署・期限）

## 🏭 部署別サマリー

### PM部
- [状況まとめ]

### 開発部
- [状況まとめ]

### マーケ部
- [状況まとめ]

### 営業部
- [状況まとめ]

## ⚡ 来週の優先事項
1. 優先タスク1
2. 優先タスク2
3. 優先タスク3

## 📚 ナレッジ蓄積
| 部署 | プレイブック数 | 最終更新 | 主なトピック |
|------|-------------|---------|------------|
| PM部 | N件 | YYYY-MM-DD | [トピック一覧] |
| 開発部 | N件 | YYYY-MM-DD | [トピック一覧] |
| マーケ部 | N件 | YYYY-MM-DD | [トピック一覧] |
| 営業部 | N件 | YYYY-MM-DD | [トピック一覧] |
| 経営企画部 | N件 | YYYY-MM-DD | [トピック一覧] |
```

## 実行手順

1. 対象フォルダのファイルを読み込む（Globでファイル一覧取得 → Readで内容確認）
2. データが存在しない部署は「記録なし」と記載する
3. レポートを生成して表示する
4. `company/reports/YYYY-MM-DD-[type]-report.md` として保存する
5. 保存完了を報告する

## 注意事項

- `company/` フォルダが存在しない場合は「まず `/company setup` でセットアップを行ってください」と伝える
- ファイルが空または存在しない部署は「データなし」と記載してスキップする
- 日本語で、読みやすく簡潔にまとめる
