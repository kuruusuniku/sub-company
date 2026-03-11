# GitHub Issues 連携ガイド

## セットアップ手順

秘書として以下の手順でユーザーを案内する。

---

### STEP 1：導入説明

以下のメッセージを表示する：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋  タスク管理の設定をしましょう！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GitHub Issues を使うと、タスク管理が
とても楽になります！

設定すると、こんなことができます：

✅ お仕事を頼むたびに、タスクを自動で記録
✅ どの部署が対応中か、ひと目でわかる
✅ 終わったタスク・進行中のタスクを一覧で確認
✅ 確認が必要なときは、お知らせが届く

かんたんな設定だけで始められます！
所要時間：約5分
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### STEP 1.5：準備確認

秘書はここから各種コマンドを **Bash ツールで直接実行** する。
ユーザーにターミナル操作を求めることは原則しない。

唯一の例外：
- `gh auth login`（ブラウザでの GitHub ログイン）
- カンバンボードの「Auto-add」トグル ON（Web UI）

この2つだけはユーザーに手動操作をお願いする。

---

### STEP 2：GitHub CLI の確認（秘書が自動実行）

秘書が以下を Bash で実行する：

```bash
gh --version
```

**バージョンが表示された場合** → STEP 3 へ進む。

**コマンドが見つからない場合** → 以下のメッセージを表示してインストールを案内する：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  ひとつだけ準備が必要です
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GitHub と連携するためのツールを
インストールしてください。

【Mac の場合】
  1. ターミナルを開く
     （⌘ + スペース →「ターミナル」と入力）
  2. 以下をそのまま貼り付けて Enter：
       brew install gh

  ※「brew が見つからない」と出た場合は、
    先に以下を貼り付けて Enter：
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

【Windows の場合】
  1. 以下のページを開いてください：
       https://cli.github.com/
  2.「Download for Windows」をクリック
  3. ダウンロードしたファイルを開いてインストール

✅ できたら「できました」とお知らせください！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

ユーザーが「できました」と伝えたら、再度 `gh --version` を Bash で実行して確認し STEP 3 へ。

---

### STEP 3：認証状態の確認（秘書が自動実行）

秘書が以下を Bash で実行する：

```bash
gh auth status
```

**ログイン済みの場合** → STEP 4 へ進む。

**未ログインの場合** → 以下のメッセージを表示する：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐  GitHub にログインしましょう
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ブラウザで GitHub にログインしていただきます。
（1分くらいで終わります！）

【手順】
  1. ターミナルを開いてください
     Mac：⌘ + スペース →「ターミナル」
     Windows：スタートメニュー右クリック →「ターミナル」

  2. 以下をそのまま貼り付けて Enter：
       gh auth login

  3. ブラウザが自動で開きます。
     GitHub のアカウントでログインしてください。

✅ ログインできたら「できました」と
   お知らせください！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

ユーザーがログイン完了を伝えたら、秘書が再度 `gh auth status` を Bash で実行して確認する。

**ログイン確認後、秘書が GitHub ユーザー名を取得する（必須）：**

```bash
gh api user --jq '.login'
```

**重要：** ここで取得したユーザー名を以降の全ステップで使用する。
`gh auth status` の表示名やユーザーの自己申告ではなく、**必ずこのコマンドの出力値を使うこと。**
（URL の組み立て、リポジトリの `owner` 確認、カンバンボードのリンク生成すべてに使う）

---

### STEP 4：リポジトリの作成（秘書が自動実行）

秘書が以下のメッセージを表示する：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁  タスクの保管場所を作ります
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
「my-tasks」という名前で、あなた専用の
タスク保管場所を作成します。

（他の人からは見えない設定です）

よろしいですか？
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

ユーザーが「OK」「はい」など了承したら、秘書が以下を Bash で実行する：

```bash
gh repo create my-tasks --private
```

ユーザーが別のリポジトリ名を伝えた場合はそちらを使用する。

**エラーハンドリング：**
- `already exists` エラー → リポジトリは既に存在するので、そのまま STEP 5 へ進む
- 認証エラー → STEP 3 に戻り `gh auth login` を再案内する
- その他のエラー → エラー内容をユーザーに表示し、対処法を案内する

作成後、秘書が以下を Bash で実行して `owner/repo` 形式を取得する：

```bash
gh repo view my-tasks --json nameWithOwner --jq '.nameWithOwner'
```

**重要：** ここで取得した `owner` が、以降の全ステップで使用する正式なユーザー名となる。
仮の値やログイン名で代用せず、必ずこのコマンドの出力を使うこと。

取得した値を控えて STEP 5 へ進む。

---

### STEP 5：ラベルの自動作成（秘書が自動実行）

秘書が以下のメッセージを表示する：

```
🏷️  部署ラベルを作成しています...
```

秘書が以下のコマンドをすべて Bash で実行する（`[repo]` は STEP 4 で取得した `owner/repo`）：

```bash
gh label create "PM部" --color "0075ca" --repo [repo] --force
gh label create "開発部" --color "e4e669" --repo [repo] --force
gh label create "マーケ部" --color "d93f0b" --repo [repo] --force
gh label create "営業部" --color "0e8a16" --repo [repo] --force
gh label create "経営企画部" --color "5319e7" --repo [repo] --force
gh label create "品質管理部" --color "b60205" --repo [repo] --force
gh label create "秘書室" --color "f9d0c4" --repo [repo] --force
gh label create "要確認" --color "e11d48" --repo [repo] --force
gh label create "自律実行中" --color "1d76db" --repo [repo] --force
gh label create "完了" --color "0e8a16" --repo [repo] --force
```

全ラベル作成後、以下を表示する：

```
✅ 10個のラベルを作成しました！
```

STEP 5.5 へ進む。

---

### STEP 5.5：カンバンボード（GitHub Projects）の作成（秘書が自動実行）

秘書が以下のメッセージを表示する：

```
📋  カンバンボードを作成しています...
```

#### ① ボード作成（秘書が Bash で実行）

```bash
gh project create --owner @me --title "タスクボード" --format json
```

出力から **プロジェクト番号**（URL 末尾の数字）を取得する。

#### ② リポジトリ紐付け（秘書が Bash で実行）

```bash
gh project link [プロジェクト番号] --owner @me --repo [repo名]
```

#### ③ フィールドID取得（秘書が Bash で実行）

```bash
# プロジェクトの node_id を取得
gh project list --owner @me --format json --jq '.projects[] | select(.title=="タスクボード") | .id'

# Status フィールドの ID とオプション ID を取得
gh project field-list [プロジェクト番号] --owner @me --format json --jq '.fields[] | select(.name=="Status") | {id, options}'
```

取得した以下の値を **config.md に自動保存** する：
- `github_project_node_id`（プロジェクトの node_id）
- `github_status_field_id`（Status フィールドの ID）
- `github_status_todo_id`（Todo の option_id）
- `github_status_inprogress_id`（In Progress の option_id）
- `github_status_done_id`（Done の option_id）

#### ④ 自動追加の設定（ユーザーに手動操作を依頼）

秘書が GitHub ユーザー名を `gh api user --jq '.login'` で取得し、以下のメッセージを表示する：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✋  あとひとつだけお願いします！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
新しいタスクが自動でボードに追加されるように
設定します。（1分で終わります！）

【手順】
  1. 以下の URL をブラウザで開いてください：
     https://github.com/users/[ユーザー名]/projects/[プロジェクト番号]

  2.「Workflows」をクリック
    （画面上のほう、「…」の横にあります）

  3. 左の一覧から
    「Auto-add to project」をクリック

  4. 右上の「Edit」をクリック

  5.「Filters」という欄が表示されます。
     以下の内容になっていることを確認してください：
       is:issue repo:[owner/my-tasks]

     もし空っぽだったり違う内容の場合は、
     上の1行をそのままコピペしてください。

  6.「Save and turn on workflow」をクリック

✅ できたら「できました」とお知らせください！

💡 うまくいかない場合は、お気軽にどうぞ。
   別の方法をご案内します。
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

ユーザーが完了を伝えたら STEP 6 へ進む。
ページが見つからない場合は、`gh api user --jq '.login'` でユーザー名を再確認し、正しい URL を案内する。

---

### STEP 6：config.md に保存（秘書が自動実行）

秘書が `company/secretary/config.md` に以下を自動追記する：

```markdown
- **github_repo**: [owner/repo]
- **github_project**: [プロジェクト番号（例: 1）]
- **github_project_node_id**: [node_id]
- **github_status_field_id**: [field_id]
- **github_status_todo_id**: [option_id]
- **github_status_inprogress_id**: [option_id]
- **github_status_done_id**: [option_id]
- **github_setup_at**: [YYYY-MM-DD]
```

`github_project` と各フィールドIDが設定されていれば `/ask` 実行時にカンバンのステータスも自動更新する。
フィールドIDが未保存の場合は Issue 作成のみ行い、カンバン操作はスキップする。

---

### STEP 7：完了メッセージ

**まず秘書がリポジトリとプロジェクトの実在確認を Bash で実行する：**

```bash
# リポジトリが存在するか確認
gh repo view [owner/repo] --json nameWithOwner --jq '.nameWithOwner'

# プロジェクトが存在するか確認
gh project list --owner @me --format json --jq '.projects[] | select(.title=="タスクボード") | .number'
```

- 両方確認できた → 以下の完了メッセージを表示する
- リポジトリが見つからない → STEP 4 に戻る
- プロジェクトが見つからない → STEP 5.5 に戻る

`owner/repo` を使って完了メッセージを表示する：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉  設定が完了しました！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
これでタスク管理の準備は完了です！

📌 タスク一覧はこちら：
   https://github.com/[owner/repo]/issues

📋 タスクボード（カンバン）はこちら：
   https://github.com/users/[owner]/projects/[github_project]

タスクボードでは、タスクが
「やること → 作業中 → 完了」の3列で
ひと目で確認できます。

どちらもブックマークしておくと便利です！

─────────────────────────────
これから /ask でお仕事を頼むと、
私が自動でタスクを記録・管理します。

確認してほしいことがあるときは、
こちらのチャットでお知らせしますね。

さっそく試してみましょう！
  /ask [なんでもご依頼ください]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### STEP 7.5：Issue の使い方と日本語化を案内する

セットアップ完了後、以下のメッセージを表示してユーザーにIssueの基本と日本語化を教える：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖  タスク画面のかんたんガイド
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

タスク（Issue）は「付箋」のようなものです。
お仕事を頼むたびに、私が自動で作って整理します。
付箋貼りの達人と呼んでください。

【画面の見方】
  Open（緑）  ＝ まだ終わっていないタスク
  Closed（紫）＝ 終わったタスク

【色タグの意味】
  🔵 PM部・開発部・マーケ部 … どの部署が担当か
  🔴 要確認  ＝ あなたの判断が必要です！
  🔵 自律実行中 ＝ 私がせっせと作業中です
  🟢 完了    ＝ おつかれさまでした！

【よく使う操作】
  ・タスクをクリック → 詳しい内容を確認
  ・「Close issue」ボタン → 完了にする
  ・コメント欄 → 追加の指示や返答を書く

基本的には私がぜんぶ管理しますので、
🔴「要確認」が付いたときだけ見てください！
それ以外はコーヒーでも飲んでお待ちください。

─────────────────────────────
🌐  画面を日本語にする方法
─────────────────────────────
GitHub は英語の画面ですが、ブラウザの
翻訳機能でかんたんに日本語にできます：

【Chrome の場合】
  1. ページ上で右クリック
  2.「日本語に翻訳」を選択

【Safari の場合】
  1. アドレスバー右端の「翻訳」アイコンをタップ
  2.「日本語に翻訳」を選択

⚠️ 「Close issue」などのボタンは
  翻訳されないことがあります。
  「Close ＝ 終わり！」と覚えてください。
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Issue操作リファレンス

`/ask` コマンドが参照する操作手順。

### Issue作成

```bash
gh issue create \
  --repo [github_repo] \
  --title "[依頼内容の要約（50文字以内）]" \
  --body "$(cat <<'EOF'
## 依頼内容
[ユーザーの依頼をそのまま記載]

## 担当部署
[部署名]

## 実行内容
[秘書が発行した命令の内容]

## 成果物
[作成されたファイルパスや内容の概要]

## ステータス
- [x] 命令発行
- [ ] 実行完了
- [ ] ユーザー確認

---
*自動作成 by [秘書名]*
EOF
)" \
  --label "[部署名]" \
  --label "自律実行中"
```

### カンバンへの追加・列移動

`config.md` に `github_project` が設定されている場合のみ実行する。

```bash
# ① Issue の URL を取得する（issue create の出力から取得）
ISSUE_URL="https://github.com/[github_repo]/issues/[番号]"

# ② プロジェクトに追加して item-id を取得
ITEM_ID=$(gh project item-add [github_project] --owner @me --url "$ISSUE_URL" --format json --jq '.id')

# ③ ステータスフィールドのIDとオプションIDを取得（初回のみ。config に保存しておく）
gh project field-list [github_project] --owner @me --format json --jq '.fields[] | select(.name=="Status") | {id, options}'
# → field_id と各列の option_id（Todo / In Progress / Done）をメモして config.md に保存

# ④ 列を「In Progress」に設定
gh project item-edit \
  --project-id [project_node_id] \
  --id "$ITEM_ID" \
  --field-id [status_field_id] \
  --single-select-option-id [in_progress_option_id]
```

**初回セットアップ後 config.md に以下を追記しておく：**
```markdown
- **github_project_node_id**: [node_id]
- **github_status_field_id**: [field_id]
- **github_status_todo_id**: [option_id]
- **github_status_inprogress_id**: [option_id]
- **github_status_done_id**: [option_id]
```

これらが保存されていれば、以降は `/ask` が自動でステータスを切り替える。
保存されていない場合はIssue作成のみ行い、カンバン操作はスキップする。

---

### ステータス更新（完了時）

```bash
# 完了ラベルに変更
gh issue edit [番号] \
  --repo [github_repo] \
  --remove-label "自律実行中" \
  --add-label "完了"

# 完了コメントを追加
gh issue comment [番号] \
  --repo [github_repo] \
  --body "✅ 対応完了しました。成果物：[ファイルパス]"

# Issueをクローズ
gh issue close [番号] --repo [github_repo]
```

### 確認事項が発生した場合

```bash
# 要確認ラベルを追加してコメント
gh issue edit [番号] \
  --repo [github_repo] \
  --add-label "要確認"

gh issue comment [番号] \
  --repo [github_repo] \
  --body "⚠️ 確認事項が発生しました。\n\n**確認内容：** [具体的な質問]\n\n**背景：** [なぜ確認が必要か]\n\nご回答いただき次第、作業を再開いたします。"
```

チャットでも同時に通知する：
「[秘書名]より確認のご連絡です。Issue #[番号] について、[確認事項] をご判断いただけますでしょうか？」

### Issue一覧確認

```bash
# 進行中のIssue一覧
gh issue list --repo [github_repo] --label "自律実行中"

# 要確認のIssue一覧
gh issue list --repo [github_repo] --label "要確認"
```

---

## 自律ステータス管理ルール

秘書として以下のルールでIssueを管理する：

| 状況 | 対応 |
|------|------|
| 命令発行直後 | Issue作成、ラベル「自律実行中」 |
| 実行完了 | ラベルを「完了」に変更、クローズ |
| 判断に迷う点がある | ラベルに「要確認」追加、チャットで通知 |
| 品質管理部からNG | ラベルに「要確認」追加、修正内容をコメント |
| ユーザーから追加指示 | コメントに記録し、関連部署へ再命令 |

---

## /report コマンドとの連携

`/report` 実行時、GitHub連携済みであれば：

```bash
# 今週クローズされたIssue
gh issue list --repo [github_repo] --state closed --limit 20

# 現在進行中
gh issue list --repo [github_repo] --label "自律実行中"

# 要確認
gh issue list --repo [github_repo] --label "要確認"
```

これらをレポートに組み込んでまとめる。
