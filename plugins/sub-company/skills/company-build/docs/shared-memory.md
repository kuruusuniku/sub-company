# 共有メモリシステム（3層メモリ）

## 概要
サブカンパニーの知識管理を3層構造で体系化する。
CrewAIの共有メモリシステムを参考にしつつ、バックエンド切替可能な設計で実現する。

## バックエンド設定

`company/secretary/config.md` に以下を追加して選択する：

```markdown
- memory_backend: markdown  # markdown / engram
```

| 設定値 | バックエンド | 特徴 |
|--------|------------|------|
| `markdown` | Markdownファイル | **デフォルト**。外部依存なし。Glob+Readで検索 |
| `engram` | engram MCPサーバー | ハイブリッド検索（FTS5+ベクトル）。大規模データに強い |

**設定がない場合は `markdown` として動作する。**

## 3層メモリ構造

### 1. 短期記憶（Session Memory）
**保存先**: `company/memory/sessions/YYYY-MM-DD-NNN.md`
**寿命**: セッション終了後、7日間保持。その後アーカイブ。

現在の依頼に関するコンテキスト情報を管理する:
- 現在の依頼内容と目的
- 実行中のタスクの中間状態
- 部署間で共有すべき一時的な情報
- ユーザーとの対話から得た補足情報

#### フォーマット
```markdown
# セッション記憶: {依頼の要約}

- **作成日時**: YYYY-MM-DD HH:MM
- **依頼者**: ユーザー
- **関連命令**: No.XXX

## コンテキスト
{依頼の背景・目的}

## 部署間共有情報
{各部署が参照すべき情報}

## メモ
{実行中に得た追加情報}
```

### 2. 長期記憶（Playbook Memory）
**保存先**: `company/[部署フォルダ]/playbooks/*.md`（既存のプレイブック機能）
**寿命**: 永続。10件を超えたら統合。

再利用可能なパターン・ベストプラクティス・教訓を蓄積する。
※ 既存のプレイブック機能がそのまま長期記憶として機能する。変更不要。

### 3. エンティティ記憶（Entity Memory）
**保存先**: `company/memory/entities/`
**寿命**: 永続。手動削除まで保持。

ユーザー・プロジェクト・外部サービスなどの固有情報を管理する:

#### エンティティの種類

| 種類 | ファイル | 内容 |
|------|---------|------|
| ユーザー | `user.md` | ユーザーの役割・好み・スキル・過去の依頼傾向 |
| プロジェクト | `project-{名前}.md` | プロジェクト固有の情報・技術スタック・制約 |
| クライアント | `client-{名前}.md` | クライアント情報・過去のやり取り・好み |
| サービス | `service-{名前}.md` | 外部サービスの接続情報・API仕様メモ |

#### エンティティファイルのフォーマット
```markdown
# エンティティ: {名前}

- **種類**: user / project / client / service
- **作成日**: YYYY-MM-DD
- **最終更新**: YYYY-MM-DD

## 基本情報
{基本的な属性情報}

## 関連情報
{依頼実行時に参考になる情報}

## 更新履歴
- [YYYY-MM-DD] {更新内容}
```

## メモリの活用フロー

### 依頼受付時（ステップ1の後）
1. `company/memory/entities/user.md` を読み、ユーザー情報を確認
2. 依頼内容に関連するエンティティ（project, client等）を検索
3. 短期記憶を新規作成し、コンテキストを記録

### 部署実行時（サブエージェント prompt に含める）
1. 関連する短期記憶のコンテキストを渡す
2. プレイブック（長期記憶）の参照手順は既存通り
3. 関連エンティティの情報があれば渡す

### 完了後（ステップ6の後）
1. 短期記憶にタスク結果のサマリーを追記
2. エンティティに更新すべき情報があれば更新
3. プレイブックの更新は既存フロー通り

## メモリの保守

### 短期記憶のアーカイブ
- 7日以上経過したセッション記憶は `company/memory/archive/` に移動
- アーカイブは月次で自動削除（秘書が `/sub-company:report` 実行時にチェック）

### エンティティの更新
- 依頼実行中にエンティティの情報が古いと判断した場合、タスク完了後に更新
- 「この情報は最新ですか？」とユーザーに確認してから更新

---

## engram バックエンド

### 概要
engram（memory-mcp-server）は永続的AIメモリのMCPサーバー。
ハイブリッド検索（FTS5全文検索 + ベクトル類似度）と A-MEM式 Zettelkasten構造化を提供する。

### 前提条件
- engram MCPサーバーが設定済みであること
- `mcp__engram__*` ツールが利用可能であること

### 3層メモリとengram MCPツールの対応

| メモリ層 | markdownバックエンド | engramバックエンド |
|---------|---------------------|-------------------|
| **短期記憶** | `company/memory/sessions/*.md` に Read/Write | `memory_save` で role=system, session_id=命令ID で保存 |
| **長期記憶** | `company/[部署]/playbooks/*.md` に Glob+Read | `memory_search` で project=部署名, tags=playbook で検索 |
| **エンティティ** | `company/memory/entities/*.md` に Read/Write | `memory_save` で tags=[entity,種類], `memory_search` で検索 |

### engram利用時の操作手順

#### 依頼受付時（ステップ1.5）
```
1. memory_search(query=依頼内容の要約, tags=["entity"], limit=5)
   → 関連エンティティを取得
2. memory_search(query=依頼内容の要約, tags=["session"], limit=3, date_from=7日前)
   → 直近の関連セッションを取得
3. memory_save(content=依頼内容, role=system, session_id=命令ID, tags=["session"], project=部署名)
   → 新規セッション記憶を保存
```

#### 部署実行時（プレイブック参照）
```
1. memory_search(query=タスク内容, tags=["playbook"], project=部署名, limit=5)
   → 関連プレイブックを取得
2. memory_associate(note_id=関連ノートID)
   → 連想検索で関連知見を発見（セレンディピティ）
```

#### 完了後（記憶の更新）
```
1. memory_save(content=タスク結果サマリー, role=assistant, session_id=命令ID, tags=["session"])
   → セッション記憶に結果を追記
2. memory_save(content=新たな知見, role=system, tags=["playbook"], project=部署名)
   → プレイブックとして保存（知見がある場合のみ）
3. memory_save(content=エンティティ更新情報, role=system, tags=["entity", 種類])
   → エンティティ更新（必要な場合のみ）
```

### engram の利点
- **セマンティック検索**: キーワード一致ではなく意味で検索できる
- **連想検索**: `memory_associate` による偶然の発見（プレイブック間の意外な関連）
- **スケーラビリティ**: SQLiteバックエンドでファイル数の制限なし（10件統合ルール不要）
- **自動構造化**: A-MEM式でサマリー・キーワード・タグが自動生成される

### engram 未設定時のフォールバック
`memory_backend: engram` が設定されているが engram MCPツールが利用不可の場合：
- 警告を表示し、markdown バックエンドにフォールバックする
- 「engram MCPサーバーが見つかりません。Markdownモードで動作します」と通知
