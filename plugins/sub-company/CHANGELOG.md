# CHANGELOG

## [1.1.0] - 2026-04-01

### 追加
- **Cowork互換性モード**: Cowork環境で安定動作するナーフ版を導入
  - `environment: cowork` 設定で自動切り替え
  - `/company setup cowork` でCoworkモード初期化に対応
  - `docs/cowork-compatibility.md` に互換性ガイドを追加

### Coworkモードで無効化される機能
- GitHub Issues連携（setup-github含む）
- launchd通知（リマインド）
- 開発パイプラインモード（E2E）
- CEO夜間モードのスケジュール登録（at/cron）（即時実行は有効）
- Bashツール実行全般

### Coworkモードで有効な機能
- `/ask` による秘書への依頼（parallel/sequential/inline全モード対応）
- Agent spawn（サブエージェント並列実行）
- 子会社設立・ダッシュボード
- プレイブック（ナレッジ）参照・更新
- 共有メモリ（markdownバックエンド）
- 品質管理部レビュー
- TODO管理・レポート生成

## [1.0.0] - 2026-04-01

### 追加
- **agentskills.io 標準対応**: スキル・コマンドのメタデータを agentskills.io 仕様に準拠
  - SKILL.md / 各コマンドの frontmatter に schema_version, capabilities, inputs, outputs 等を追加
  - `agentskills.json` スキルパックマニフェストを新規作成
- **オブザーバビリティ基盤（Phase 1）**: 実行トレーシングログの自動記録
  - 各Agent実行の開始・完了・所要時間・エラーを `company/logs/YYYY-MM-DD-trace.md` に出力
  - 日次サマリー（総命令数・成功率・稼働部署）を自動生成
- **ブラウザ統合**: 品質管理部のQAレビューにブラウザベースの視覚的テストを導入
  - `browser_backend` 設定で切り替え可能: `claude-in-chrome`（推奨） / `gstack` / `none`
  - claude-in-chrome: MCPツールで直接ブラウザ操作。外部依存なし
  - gstack: Persistent Chromium Daemon 経由。要インストール
  - 未設定時は利用可能なバックエンドを自動判定
- **共有メモリシステム（3層メモリ）**: CrewAI 型の知識管理を導入
  - 短期記憶（Session Memory）: 依頼ごとのコンテキスト管理
  - 長期記憶（Playbook Memory）: 既存プレイブック機能を長期記憶として位置づけ
  - エンティティ記憶（Entity Memory）: ユーザー・プロジェクト・クライアント等の固有情報
  - `memory_backend` 設定で切り替え可能: `markdown`（デフォルト） / `engram`
  - engram: MCP サーバー経由のハイブリッド検索（FTS5 + ベクトル）+ 連想検索 + A-MEM 自動構造化
  - 未設定時は markdown バックエンドで動作
- **3ツール間連携パイプライン**: サブカンパニー → 孔明 → タチコマ の E2E 開発自動化
  - 「開発パイプラインで」等のキーワードでパイプラインモード発動
  - `.context.md` による統一コンテキストファイルで3ツール間のデータ受け渡し
  - 各ツールの利用可能性を自動判定し、未インストール時はセットアップを案内

### 変更
- ask.md にステップ1.5（共有メモリ参照）、ステップ2P（パイプラインモード）、ステップ5.5（実行ログ記録）を追加
- departments.md の品質管理部セクションにブラウザベースQAの説明を追加

### 修正
- plugin.json のバージョンを実態に合わせて更新（#14）

---

## [0.9.0] - 2026-03-27

### 追加
- **macOS launchd 通知機能（さくらリマインド）**: スケジュール通知を launchd plist ベースで実装
  - `sakura-remind-set.sh`: 指定日時に通知を設定（plist 生成 + launchctl ロード）
  - `sakura-remind-list.sh`: 設定済み通知の一覧表示
  - `sakura-remind-clear.sh`: 全通知 or 指定通知の削除
  - `sakura-remind.sh`: 通知表示 + plist 自動削除（ワンショット動作）
  - Mac 再起動・スリープ復帰後も動作する堅牢な通知
  - 非 macOS 環境では従来の sleep 方式にフォールバック
- ask.md にスケジュール通知提案フローを追加（キーワード検出 → 通知提案 → 設定）
- `docs/features/mac-notifications.md` に機能説明ドキュメントを追加

---

## [0.8.0] - 2026-03-13

### 追加
- **プレイブック（ナレッジ学習）機能**: 各部署が仕事を通じて知見を蓄積し、次回以降に活かす仕組み
  - サブエージェントがタスク実行前に `playbooks/*.md` を自動参照
  - タスク完了後に再利用可能な知見をプレイブックとして保存・更新
  - 1部署あたり最大10件、超えたら関連性の高いもの同士を統合
  - 結果レポートに「参照したプレイブック」項目を追加
  - CEO・品質管理部にもプレイブック参照・更新を追加
  - inline モード実行時も同様にプレイブックを参照
- `/company setup` で各部署フォルダに `playbooks/` ディレクトリを自動作成
- `/report` にナレッジ蓄積セクションを追加（部署別プレイブック数・トピック一覧）

---

## [0.7.0] - 2026-03-11

### 変更（Claude Code 対応）
- **Claude Code プラグイン形式に変換** — Cowork 専用から Claude Code で配布可能な形式に変更
- `AskUserQuestion` を全コマンドから削除（Claude Code では利用不可のため）
  - ask.md：メニュー表示はチャット内テキストに変更
  - company.md：セットアップのヒアリングをチャット直接質問に変更
  - ceo.md：夜間タスク設定をチャット直接質問に変更
- `allowed-tools` に `Grep` を追加（Claude Code で利用可能）
- CEO 夜間モード：`mcp__scheduled-tasks` を廃止し、`at` コマンド / `cron` / 即時実行の3方式に変更
- README.md を配布用に全面書き直し（インストール手順・クイックスタート等）
- description を Claude Code 向けに更新

---

## [0.6.0] - 2026-03-11

### 追加
- **CEO ロール**: 必要なときだけ召喚できる経営レイヤー
  - `/ask CEOを呼んで` で CEO モード発動（戦略分析→部署指示→成果物レビュー）
  - `/ceo` コマンド新設：即時実行 / 夜間モード / ステータス確認の3機能
  - 夜間自律実行モード：スケジュールタスクで登録、ユーザー不在で自律的に計画→実行→レビュー
  - 朝の結果レポート（`/ceo ステータス`）で夜間タスクの成果を確認
  - CEO 専用フォルダ `company/ceo/`（plans / reviews / reports / orders）

### 変更
- ask.md に CEO モード分岐（ステップ2C）を追加
- SKILL.md に CEO ロールセクション・フォルダ構成を追加

---

## [0.5.0] - 2026-03-11

### 追加
- **サブエージェント並列実行**: 各部署を Agent ツールでサブエージェントとして spawn し、複数部署を同時に実行可能に
- **命令書の部署フォルダ格納**: 命令書を `company/[部署]/orders/order-YYYY-MM-DD-NNN.md` に保存、結果も `result-YYYY-MM-DD-NNN.md` で部署フォルダに返す構成に
- **実行モード制御**: `config.md` の `execution_mode` で parallel / sequential / inline の3モードを切り替え可能に
  - parallel：複数部署を同時 spawn（デフォルト）
  - sequential：1部署ずつ順番に spawn（プラン節約）
  - inline：サブエージェントなし、秘書が直接実行（最小消費）
- 「節約モードで」「全力で」などの口頭指示でもモード即座切り替え対応

### 変更
- ask.md を全面改修：ステップ3を「サブエージェント spawn → 結果収集」方式に
- allowed-tools に `Agent` を追加
- 品質管理部のレビューもサブエージェントとして独立実行する形に変更
- SKILL.md に「実行アーキテクチャ」セクション追加
- ユーザー向けメッセージをやさしい表現に全面書き直し
- 秘書のトーン・ユーモア方針を SKILL.md に明記

---

## [0.4.0] - 2026-03-11

### 変更
- **GitHub セットアップ手順を「秘書が自動実行」スタイルに全面改修**
  - STEP 2（GitHub CLI 確認）：秘書が `gh --version` を Bash で直接実行する形式に変更
  - STEP 3（認証確認）：秘書が `gh auth status` を Bash で直接実行する形式に変更
  - STEP 4（リポジトリ作成）：秘書が `gh repo create` を Bash で直接実行する形式に変更
  - STEP 5（ラベル作成）：秘書が全10ラベルを Bash で一括自動作成する形式に変更
  - STEP 5.5（カンバンボード作成）：秘書がボード作成・リポジトリ紐付け・フィールドID取得を Bash で自動実行する形式に変更

- **STEP 1.5 を簡略化**
  - ターミナルの開き方案内を削除（秘書が直接実行するため不要に）
  - 手動操作が必要な2箇所（`gh auth login` / Auto-add トグル）のみを明記

- **STEP 5.5 にフィールドID自動取得ロジックを追加**
  - `gh project field-list` で Status フィールドID・各ステータスの option_id を自動取得
  - 取得した値を config.md に自動保存する手順を追加

- **STEP 6（config.md 保存）を拡充**
  - `github_project_node_id` / `github_status_field_id` / 各ステータスIDの保存項目を追加
  - フィールドID未保存時はカンバン操作をスキップするルールを明記

---

## [0.3.0] - 2026-03-11

### 追加
- **GitHub Projects カンバンボード対応**
  - STEP 5.5 でカンバンボード（タスクボード）を自動作成
  - Issue 作成時に自動で「In Progress」列へ移動
  - 完了時に「Done」列へ移動してクローズ
  - セットアップ完了後にカンバンボードの URL を案内

- **Issueの使い方ガイドを追加**（STEP 7.5）
  - Open/Closed の意味、ラベルの色と役割を説明
  - 「要確認が付いたときだけ見ればOK」という運用方針を案内

- **GitHub 画面の日本語化ガイドを追加**
  - Chrome・Safari それぞれの翻訳手順を案内
  - 翻訳されないボタン（Close など）の補足説明

- **GitHub リポジトリ作成を `my-tasks` に固定**
  - 選択肢をなくし「そのまま実行」できるコマンドを提示
  - 別名を使いたい場合のみ任意入力

- **完了報告に Issue 一覧・カンバンボードのリンクを追加**

### 変更
- STEP 4 をリポジトリ選択（3択）→ `my-tasks` 推奨の直接案内に変更
- `company/secretary/config.md` に `github_project` など5フィールドを追加

---

## [0.2.0] - 2026-03-11

### 追加
- **GitHub Issues 連携機能**（`/company setup-github`）
  - `gh` CLI を使った認証・リポジトリ設定フローを実装
  - 10種のラベルを自動作成（PM部・開発部・マーケ部・営業部・経営企画部・品質管理部・秘書室・要確認・自律実行中・完了）
  - `/ask` 実行時に Issue を自動作成・ステータス管理
  - 確認事項発生時にチャットで通知

- **品質管理部（Devil's Advocate）を追加**
  - 対外向け資料・重要成果物を自動レビュー
  - 要修正 / 条件付き承認 / 承認 の3段階判定
  - `company/qa/reviews/` にレビュー記録を保存

- **`/ask` 引数なし起動**
  - AskUserQuestion で8択メニューを表示
  - 秘書が用件を聞くフローを実装

- **3件ログ後に GitHub セットアップを提案**（一度だけ）

### 変更
- CEO ロールを廃止、秘書が全部署へ直接命令する体制に変更
- 全部署を `/company setup` 時に自動作成（選択式を廃止）
- セットアップ完了メッセージを「まず `/ask` と入力してください」に変更

---

## [0.1.0] - 2026-03-10

### 初版リリース
- `/company` コマンド（セットアップ・ダッシュボード・名前変更）
- `/ask` コマンド（秘書が部署へ命令を発行して実行）
- `/report` コマンド（週次・月次・部署別レポート生成）
- 秘書室・PM部・開発部・マーケ部・営業部・経営企画部の6部署
- 秘書名・トーンを `company/secretary/config.md` に保存
- 対応ユースケース：プロジェクト管理・技術調査・マーケ戦略・提案書・台本・お知らせ文面・売上分析・デザインリサーチ・資料チェック
