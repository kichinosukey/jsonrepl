#!/bin/bash

set -e

# ディレクトリの定義
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/jsonrepl"
SCRIPT_NAME="jsonrepl"

# 現在のディレクトリ
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# スーパーユーザー権限の確認
if [ "$(id -u)" -ne 0 ]; then
  echo "インストールには管理者権限が必要です。sudo を使用してください。"
  echo "実行方法: sudo $0"
  exit 1
fi

# 設定ディレクトリの作成
mkdir -p "$CONFIG_DIR"

# 現在のユーザーを取得
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo ~$REAL_USER)
USER_CONFIG_DIR="$REAL_HOME/.config/jsonrepl"

# 実際のユーザーの設定ディレクトリも作成
mkdir -p "$USER_CONFIG_DIR"
chown -R "$REAL_USER" "$USER_CONFIG_DIR"

# 既存の設定ファイルの移行
if [ -f "$CURRENT_DIR/conversation_table.json" ]; then
  cp "$CURRENT_DIR/conversation_table.json" "$USER_CONFIG_DIR/"
  chown "$REAL_USER" "$USER_CONFIG_DIR/conversation_table.json"
  echo "変換テーブルを $USER_CONFIG_DIR/ にコピーしました。"
else
  # デフォルトの変換テーブルを作成
  echo '{"例": "置換例"}' > "$USER_CONFIG_DIR/conversation_table.json"
  chown "$REAL_USER" "$USER_CONFIG_DIR/conversation_table.json"
  echo "デフォルトの変換テーブルを $USER_CONFIG_DIR/ に作成しました。"
fi

# スクリプトをバイナリディレクトリにコピー
cp "$CURRENT_DIR/jsonrepl.sh" "$INSTALL_DIR/$SCRIPT_NAME"
chmod 755 "$INSTALL_DIR/$SCRIPT_NAME"

echo "インストールが完了しました！"
echo "使い方:"
echo "  $SCRIPT_NAME 対象ファイル [変換テーブル.json]  - 指定したファイルを変換"
echo "  $SCRIPT_NAME table edit                    - 変換テーブルを編集"
echo "  $SCRIPT_NAME table show                    - 変換テーブルを表示"