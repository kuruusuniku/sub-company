#!/bin/bash
# さくらリマインド削除 - 全通知 or 指定通知を削除
# Usage: sakura-remind-clear.sh [ラベル]
#
# 引数なし : すべてのさくらリマインド通知を削除
# ラベル指定 : 指定したラベルの通知のみ削除
#
# 例:
#   sakura-remind-clear.sh                                          # 全削除
#   sakura-remind-clear.sh com.sakura.remind.20260327-1240-a1b2     # 指定削除

set -euo pipefail

# --- macOS 判定 ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "エラー: このスクリプトは macOS 専用です。" >&2
  exit 1
fi

PLIST_DIR="$HOME/Library/LaunchAgents"
TARGET_LABEL="${1:-}"

remove_remind() {
  local label="$1"
  local plist_file="${PLIST_DIR}/${label}.plist"

  # launchctl からアンロード
  launchctl bootout "gui/$(id -u)/${label}" 2>/dev/null || true

  # plist ファイルを削除
  if [[ -f "$plist_file" ]]; then
    rm -f "$plist_file"
    echo "  削除: ${label}"
    return 0
  else
    echo "  見つかりません: ${label}" >&2
    return 1
  fi
}

echo "=== さくらリマインド 通知削除 ==="
echo ""

if [[ -n "$TARGET_LABEL" ]]; then
  # --- 指定ラベルのみ削除 ---
  remove_remind "$TARGET_LABEL"
else
  # --- 全削除 ---
  count=0
  for plist_file in "${PLIST_DIR}"/com.sakura.remind.*.plist; do
    if [[ ! -f "$plist_file" ]]; then
      continue
    fi
    label=$(basename "$plist_file" .plist)
    remove_remind "$label"
    count=$((count + 1))
  done

  if [[ $count -eq 0 ]]; then
    echo "  削除する通知はありませんでした。"
  else
    echo ""
    echo "${count} 件の通知を削除しました。"
  fi
fi
