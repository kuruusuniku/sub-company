#!/bin/bash
# さくらリマインド一覧 - 設定済みの通知を一覧表示
# Usage: sakura-remind-list.sh
#
# ~/Library/LaunchAgents/com.sakura.remind.*.plist を走査し、
# 設定済みの通知日時・メッセージ・ラベルを表示する。

set -euo pipefail

# --- macOS 判定 ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "エラー: このスクリプトは macOS 専用です。" >&2
  exit 1
fi

PLIST_DIR="$HOME/Library/LaunchAgents"
PATTERN="com.sakura.remind.*.plist"

# --- plist 一覧取得 ---
found=0

echo "=== さくらリマインド 通知一覧 ==="
echo ""

for plist_file in "${PLIST_DIR}"/${PATTERN}; do
  if [[ ! -f "$plist_file" ]]; then
    continue
  fi

  found=$((found + 1))
  label=$(basename "$plist_file" .plist)

  # plist から情報を抽出（/usr/libexec/PlistBuddy を使用）
  month=$(/usr/libexec/PlistBuddy -c "Print :StartCalendarInterval:Month" "$plist_file" 2>/dev/null || echo "?")
  day=$(/usr/libexec/PlistBuddy -c "Print :StartCalendarInterval:Day" "$plist_file" 2>/dev/null || echo "?")
  hour=$(/usr/libexec/PlistBuddy -c "Print :StartCalendarInterval:Hour" "$plist_file" 2>/dev/null || echo "?")
  minute=$(/usr/libexec/PlistBuddy -c "Print :StartCalendarInterval:Minute" "$plist_file" 2>/dev/null || echo "?")

  # メッセージ取得（ProgramArguments の index 2）
  message=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments:2" "$plist_file" 2>/dev/null || echo "(不明)")

  # Year があれば取得
  year=$(/usr/libexec/PlistBuddy -c "Print :StartCalendarInterval:Year" "$plist_file" 2>/dev/null || echo "")

  # 表示
  if [[ -n "$year" ]]; then
    printf "  [%d] %s-%02d-%02d %02d:%02d\n" "$found" "$year" "$month" "$day" "$hour" "$minute"
  else
    printf "  [%d] %02d/%02d %02d:%02d\n" "$found" "$month" "$day" "$hour" "$minute"
  fi
  echo "      メッセージ: ${message}"
  echo "      ラベル: ${label}"
  echo ""
done

if [[ $found -eq 0 ]]; then
  echo "  設定済みの通知はありません。"
  echo ""
fi

echo "合計: ${found} 件"
