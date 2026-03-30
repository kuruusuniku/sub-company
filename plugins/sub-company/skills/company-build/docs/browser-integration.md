# ブラウザ統合ガイド

## 概要
品質管理部のQAレビューにおいて、ブラウザベースの視覚的テストを実施するためのガイド。
複数のブラウザバックエンドに対応し、`company/secretary/config.md` の設定で切り替え可能。

## バックエンド設定

`company/secretary/config.md` に以下を追加して選択する：

```markdown
- browser_backend: claude-in-chrome  # claude-in-chrome / gstack / none
```

| 設定値 | バックエンド | 特徴 |
|--------|------------|------|
| `claude-in-chrome` | Claude in Chrome MCP | **推奨**。外部依存なし。MCPツールで直接ブラウザ操作 |
| `gstack` | gstack スキルパック | Persistent Chromium Daemon。要インストール |
| `none` | ブラウザテスト無効 | 通常のコードレビューのみ |

**設定がない場合の自動判定：**
1. `mcp__claude-in-chrome__*` ツールが利用可能 → `claude-in-chrome` として動作
2. `~/.claude/skills/gstack` が存在 → `gstack` として動作
3. いずれもなし → `none`（ブラウザテストスキップ）

## 発動条件（全バックエンド共通）

品質管理部のサブエージェントが以下に該当する場合、ブラウザテストを実施する：

1. 成果物がWebアプリケーション・Webページの場合
2. UIの視覚的変更を含む場合
3. ユーザーが明示的に「ブラウザで確認」「見た目をチェック」等と要求した場合

---

## バックエンド別の実行手順

### claude-in-chrome（推奨）

外部ツール不要。MCPツールで直接ブラウザを操作する。

#### 利用可能なツール

| MCPツール | 用途 | QAでの活用 |
|----------|------|-----------|
| `mcp__claude-in-chrome__tabs_context_mcp` | 現在のタブ情報取得 | テスト開始前の状態確認 |
| `mcp__claude-in-chrome__tabs_create_mcp` | 新規タブ作成 | テスト対象ページを開く |
| `mcp__claude-in-chrome__navigate` | ページ遷移 | 対象URLへ移動 |
| `mcp__claude-in-chrome__read_page` | ページ内容取得 | 構造・コンテンツの検証 |
| `mcp__claude-in-chrome__get_page_text` | テキスト抽出 | コンテンツの正確性チェック |
| `mcp__claude-in-chrome__computer` | スクリーンショット・操作 | 視覚的検証・クリック・入力 |
| `mcp__claude-in-chrome__javascript_tool` | JS実行 | DOM検証・動的要素テスト |
| `mcp__claude-in-chrome__read_console_messages` | コンソールログ取得 | JSエラー・警告の検出 |
| `mcp__claude-in-chrome__find` | 要素検索 | 特定要素の存在確認 |
| `mcp__claude-in-chrome__gif_creator` | GIF記録 | 操作フローの記録 |

#### QA実行手順

```
1. tabs_context_mcp で現在のブラウザ状態を確認
2. tabs_create_mcp で新規タブを作成
3. navigate で対象URLに遷移
4. computer でスクリーンショットを撮影（ビフォー）
5. read_page でページ構造を取得し、以下を検証：
   - レイアウト崩れ
   - リンク切れ（href の妥当性）
   - 画像の alt 属性
   - レスポンシブ対応
6. read_console_messages でJSエラー・警告を確認
7. javascript_tool で動的要素のテスト（フォーム送信、モーダル等）
8. 検証結果をレビューレポートに含める
```

#### レポートフォーマット（claude-in-chrome）

```markdown
### ブラウザテスト結果

- **バックエンド**: claude-in-chrome
- **対象URL**: {URL}
- **テスト日時**: YYYY-MM-DD HH:MM

#### 視覚的検証
- [ ] レイアウト崩れなし
- [ ] 画像表示正常
- [ ] レスポンシブ対応（モバイル/タブレット/デスクトップ）

#### コンソール検証
- エラー: {N}件
- 警告: {N}件
- 詳細: {エラー内容}

#### インタラクション検証
- [ ] リンク遷移正常
- [ ] フォーム送信正常
- [ ] 動的要素の動作確認

#### 総合判定
✅ 問題なし / ⚠️ 軽微な問題あり / ❌ 要修正
```

---

### gstack

gstackのPersistent Chromium Daemonを利用する。

#### 前提条件
- gstackがグローバルインストールされていること（`~/.claude/skills/gstack`）

#### 利用可能なコマンド

| コマンド | 用途 | QAでの活用 |
|---------|------|-----------|
| `/browse` | Chromiumブラウザ操作 | ページアクセス・操作 |
| `/qa` | diff→テスト→修正 | 成果物の視覚的検証+自動修正 |
| `/qa-only` | テスト報告のみ | 品質レポート作成 |
| `/benchmark` | Core Web Vitals | パフォーマンス検証 |
| `/canary` | デプロイ後監視 | リリース後ヘルスチェック |

#### QA実行手順

```
1. 対象URLまたはローカルサーバーの起動を確認
2. /qa-only でスクリーンショット付きテストレポートを取得
3. 必要に応じて /benchmark でパフォーマンス計測
4. レビュー結果にスクリーンショットとヘルススコアを含める
```

---

### none（ブラウザテスト無効）

ブラウザテストを実施せず、通常のコードベースレビューのみ行う。
設定で明示的に `none` を指定するか、利用可能なバックエンドがない場合に適用される。
