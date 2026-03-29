#!/bin/bash
# さくらリマインド設定 - 指定時刻に通知する launchd plist を生成・ロード
# Usage: sakura-remind-set.sh "2026-03-27 12:40" "13:00 全体定例まであと20分です"
#
# 1. ~/Library/LaunchAgents/com.sakura.remind.YYYYMMDD-HHMM-XXXX.plist を生成
# 2. launchctl bootstrap で登録
# 3. 完了メッセージを出力
#
# 通知時刻になると sakura-remind.sh が呼ばれ、ポップアップ表示後に plist を自動削除する。

set -euo pipefail

# --- macOS 判定 ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "エラー: このスクリプトは macOS 専用です。" >&2
  exit 1
fi

# --- 引数チェック ---
if [[ $# -lt 2 ]]; then
  echo "Usage: sakura-remind-set.sh \"YYYY-MM-DD HH:MM\" \"通知メッセージ\"" >&2
  echo "" >&2
  echo "  YYYY-MM-DD HH:MM : 通知を表示する日時" >&2
  echo "  通知メッセージ     : ポップアップに表示するテキスト" >&2
  echo "" >&2
  echo "例: sakura-remind-set.sh \"2026-03-27 14:40\" \"15:00 会議まであと20分\"" >&2
  exit 1
fi

NOTIFY_DATETIME="$1"
MESSAGE="$2"

# --- 日時バリデーション（P1: 形式チェック） ---
if ! [[ "$NOTIFY_DATETIME" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}$ ]]; then
  echo "エラー: 日時は YYYY-MM-DD HH:MM 形式で指定してください: ${NOTIFY_DATETIME}" >&2
  exit 1
fi

# date コマンドでパース可能か検証
if ! date -j -f "%Y-%m-%d %H:%M" "$NOTIFY_DATETIME" "+%s" >/dev/null 2>&1; then
  echo "エラー: 無効な日時です: ${NOTIFY_DATETIME}" >&2
  exit 1
fi

# --- 過去日時チェック（P2: 警告出力） ---
notify_epoch=$(date -j -f "%Y-%m-%d %H:%M" "$NOTIFY_DATETIME" "+%s" 2>/dev/null)
now_epoch=$(date "+%s")
if [[ -n "$notify_epoch" && "$notify_epoch" -le "$now_epoch" ]]; then
  echo "警告: 指定日時は過去です: ${NOTIFY_DATETIME}" >&2
fi

# --- XMLエンティティエスケープ（P0: XMLインジェクション防止） ---
SAFE_MESSAGE=$(echo "$MESSAGE" | sed "s/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/\"/\&quot;/g; s/'/\&apos;/g")

# --- 日時パース ---
# "YYYY-MM-DD HH:MM" 形式を分解
NOTIFY_YEAR=$(echo "$NOTIFY_DATETIME" | cut -d'-' -f1)
NOTIFY_MONTH=$(echo "$NOTIFY_DATETIME" | cut -d'-' -f2)
NOTIFY_DAY=$(echo "$NOTIFY_DATETIME" | cut -d' ' -f1 | cut -d'-' -f3)
NOTIFY_HOUR=$(echo "$NOTIFY_DATETIME" | cut -d' ' -f2 | cut -d':' -f1)
NOTIFY_MINUTE=$(echo "$NOTIFY_DATETIME" | cut -d' ' -f2 | cut -d':' -f2)

# --- ラベル・パス生成 ---
RANDOM_SUFFIX=$(printf '%04x' $RANDOM)
LABEL="com.sakura.remind.${NOTIFY_YEAR}${NOTIFY_MONTH}${NOTIFY_DAY}-${NOTIFY_HOUR}${NOTIFY_MINUTE}-${RANDOM_SUFFIX}"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="${PLIST_DIR}/${LABEL}.plist"

# --- スクリプトパスの解決 ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REMIND_SCRIPT="${SCRIPT_DIR}/sakura-remind.sh"

if [[ ! -x "$REMIND_SCRIPT" ]]; then
  echo "エラー: sakura-remind.sh が見つからないか実行権限がありません: ${REMIND_SCRIPT}" >&2
  exit 1
fi

# --- LaunchAgents ディレクトリ確認 ---
mkdir -p "$PLIST_DIR"

# --- 既存の同時刻通知を削除（上書き動作） ---
for existing in "${PLIST_DIR}"/com.sakura.remind.${NOTIFY_YEAR}${NOTIFY_MONTH}${NOTIFY_DAY}-${NOTIFY_HOUR}${NOTIFY_MINUTE}-*.plist; do
  if [[ -f "$existing" ]]; then
    existing_label=$(basename "$existing" .plist)
    launchctl bootout "gui/$(id -u)/${existing_label}" 2>/dev/null || true
    rm -f "$existing"
    echo "既存通知を上書き: ${existing_label}"
  fi
done

# --- plist 生成 ---
cat > "$PLIST_FILE" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${REMIND_SCRIPT}</string>
        <string>${SAFE_MESSAGE}</string>
        <string>${LABEL}</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Year</key>
        <integer>${NOTIFY_YEAR}</integer>
        <key>Month</key>
        <integer>${NOTIFY_MONTH#0}</integer>
        <key>Day</key>
        <integer>${NOTIFY_DAY#0}</integer>
        <key>Hour</key>
        <integer>${NOTIFY_HOUR#0}</integer>
        <key>Minute</key>
        <integer>${NOTIFY_MINUTE#0}</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/sakura-remind.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/sakura-remind-error.log</string>
</dict>
</plist>
PLIST_EOF

# --- launchctl にロード ---
launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE"

echo "通知を設定しました:"
echo "  日時: ${NOTIFY_DATETIME}"
echo "  メッセージ: ${MESSAGE}"
echo "  ラベル: ${LABEL}"
echo "  plist: ${PLIST_FILE}"
