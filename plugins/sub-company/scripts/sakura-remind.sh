#!/bin/bash
# さくらリマインド - launchd から呼ばれる通知スクリプト
# Usage: sakura-remind.sh "通知メッセージ" [plist-label]
#
# - osascript display dialog でポップアップ通知
# - 通知後に自分の plist を自動アンロード・削除（ワンショット）
#
# launchd plist の ProgramArguments から呼ばれることを想定。
# 通知表示後、該当 plist を自動的にクリーンアップする。

set -euo pipefail

# --- macOS 判定 ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "エラー: このスクリプトは macOS 専用です。" >&2
  exit 1
fi

# --- 引数チェック ---
if [[ $# -lt 1 ]]; then
  echo "Usage: sakura-remind.sh \"通知メッセージ\" [plist-label]" >&2
  echo "" >&2
  echo "  通知メッセージ : ポップアップに表示するテキスト" >&2
  echo "  plist-label    : 自動削除する LaunchAgent のラベル（省略可）" >&2
  exit 1
fi

MESSAGE="$1"
PLIST_LABEL="${2:-}"

# --- メッセージのサニタイズ（AppleScriptインジェクション防止） ---
SAFE_MSG=$(echo "$MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g')

# --- 通知表示 ---
osascript -e "display dialog \"${SAFE_MSG}\" with title \"さくらリマインド\" buttons {\"OK\"} default button \"OK\" with icon note" 2>/dev/null || true

# --- plist 自動削除（ワンショット） ---
if [[ -n "$PLIST_LABEL" ]]; then
  PLIST_FILE="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"

  # launchctl bootout でアンロード（macOS 10.10+）
  launchctl bootout "gui/$(id -u)/${PLIST_LABEL}" 2>/dev/null || true

  # plist ファイルを削除
  if [[ -f "$PLIST_FILE" ]]; then
    rm -f "$PLIST_FILE"
    echo "クリーンアップ完了: ${PLIST_FILE}"
  fi
fi

echo "通知完了: ${MESSAGE}"
