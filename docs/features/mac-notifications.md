# macOS launchd 通知機能（さくらリマインド）

## 概要

macOS の launchd を利用したスケジュール通知機能です。指定した日時にポップアップ通知を表示し、通知後は自動的にクリーンアップされます。

従来の `sleep + osascript &` 方式と異なり、以下の利点があります：

- Mac の再起動・スリープ復帰後も動作する
- ターミナルセッションに依存しない
- 通知後に plist が自動削除される（ワンショット動作）

## 対応環境

- **macOS のみ**（`uname` で判定）
- 非 macOS 環境では従来の sleep 方式にフォールバック

## スクリプト一覧

すべてのスクリプトは `plugins/sub-company/scripts/` に配置されています。

### sakura-remind-set.sh — 通知を設定する

指定した日時に通知を表示する launchd plist を生成・ロードします。

```bash
# 基本的な使い方
bash sakura-remind-set.sh "2026-03-27 14:40" "15:00 会議まであと20分"

# 出力例:
# 通知を設定しました:
#   日時: 2026-03-27 14:40
#   メッセージ: 15:00 会議まであと20分
#   ラベル: com.sakura.remind.20260327-1440-a1b2
#   plist: /Users/xxx/Library/LaunchAgents/com.sakura.remind.20260327-1440-a1b2.plist
```

**引数:**
- 第1引数: 通知日時（`"YYYY-MM-DD HH:MM"` 形式）
- 第2引数: 通知メッセージ

**動作:**
1. ユニークなラベル `com.sakura.remind.YYYYMMDD-HHMM-XXXX` を生成
2. `~/Library/LaunchAgents/` に plist ファイルを作成
3. `launchctl bootstrap` でロード
4. 同時刻の既存通知があれば自動的に上書き

### sakura-remind-list.sh — 設定済み通知を一覧表示

```bash
bash sakura-remind-list.sh

# 出力例:
# === さくらリマインド 通知一覧 ===
#
#   [1] 2026-03-27 14:40
#       メッセージ: 15:00 会議まであと20分
#       ラベル: com.sakura.remind.20260327-1440-a1b2
#
# 合計: 1 件
```

### sakura-remind-clear.sh — 通知を削除

```bash
# 全通知を削除
bash sakura-remind-clear.sh

# 特定の通知のみ削除（ラベル指定）
bash sakura-remind-clear.sh com.sakura.remind.20260327-1440-a1b2
```

### sakura-remind.sh — 通知表示スクリプト（launchd から呼ばれる）

通常、ユーザーが直接実行する必要はありません。launchd が指定時刻に自動的に呼び出します。

- `osascript -e 'display dialog ...'` でポップアップ表示
- 表示後、自身の plist を `launchctl bootout` でアンロード
- plist ファイルも削除してクリーンアップ

## 秘書からの通知提案フロー

秘書がスケジュール確認時に、以下のキーワードを含む予定を検出するとリマインド通知を提案します：

- 打ち合わせ、会議、ミーティング、MTG、定例、面談
- 病院、歯医者、クリニック、通院
- 面接、商談、プレゼン、発表
- 締切、期限、提出、納品

通知は予定の20分前に設定されます（ユーザーの希望に応じて調整可能）。

## 技術詳細

### plist の構造

生成される plist は `StartCalendarInterval` を使用して特定日時に1回だけ起動します。

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Year</key><integer>2026</integer>
    <key>Month</key><integer>3</integer>
    <key>Day</key><integer>27</integer>
    <key>Hour</key><integer>14</integer>
    <key>Minute</key><integer>40</integer>
</dict>
```

### ファイル配置

- plist: `~/Library/LaunchAgents/com.sakura.remind.YYYYMMDD-HHMM-XXXX.plist`
- ログ: `/tmp/sakura-remind.log`, `/tmp/sakura-remind-error.log`

### 非 macOS フォールバック

macOS 以外の環境では、スクリプトは実行されず、代わりに以下の sleep 方式が使われます：

```bash
(sleep [秒数] && osascript -e 'display dialog "[メッセージ]"') &
```

この方式はターミナルセッションに依存するため、ターミナルを閉じると通知も消えます。
