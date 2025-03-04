#!/bin/bash

# バージョン情報
VERSION="1.0.0"

# 設定ディレクトリの定義
CONFIG_DIR="$HOME/.config/jsonrepl"
CONFIG_FILE="$CONFIG_DIR/config.json"
DEFAULT_TABLE="$CONFIG_DIR/conversation_table.json"

# 設定ディレクトリの作成
mkdir -p "$CONFIG_DIR"

# デフォルトテーブルが存在しない場合は作成
if [ ! -f "$DEFAULT_TABLE" ]; then
  echo '{"例": "置換例"}' > "$DEFAULT_TABLE"
fi

# コマンドごとの処理
case "$1" in
  "table")
    case "$2" in
      "edit")
        ${EDITOR:-vi} "$DEFAULT_TABLE"
        ;;
      "show")
        cat "$DEFAULT_TABLE"
        ;;
      *)
        echo "Usage: $0 table [edit|show]"
        exit 1
        ;;
    esac
    exit 0
    ;;
  "version")
    echo "jsonrepl version $VERSION"
    exit 0
    ;;
  "help")
    echo "jsonrepl - JSONテーブルを使ったテキスト置換ツール"
    echo ""
    echo "使い方:"
    echo "  $(basename "$0") <対象ファイル> [変換テーブル.json] - 指定したファイルをテーブルに従って変換"
    echo "  $(basename "$0") table edit                     - 変換テーブルを編集"
    echo "  $(basename "$0") table show                     - 変換テーブルを表示"
    echo "  $(basename "$0") version                        - バージョン情報を表示"
    echo "  $(basename "$0") help                           - このヘルプを表示"
    echo ""
    echo "説明:"
    echo "  対象ファイル内のテキストを、変換テーブル（JSON形式）に従って置換します。"
    echo "  変換テーブルを指定しない場合は $DEFAULT_TABLE が使用されます。"
    exit 0
    ;;
  *)
    # 引数のチェック
    if [ "$#" -lt 1 ]; then
      echo "Usage: $(basename "$0") <対象ファイル> [変換テーブル.json]"
      echo "       $(basename "$0") table [edit|show]"
      echo "       $(basename "$0") help"
      exit 1
    fi
    ;;
esac

target_file="$1"
conversion_file="${2:-$DEFAULT_TABLE}"

# ファイルの存在確認
if [ ! -f "$target_file" ]; then
  echo "Error: 対象ファイル $target_file が見つかりません"
  exit 1
fi

if [ ! -f "$conversion_file" ]; then
  echo "Error: 変換テーブル $conversion_file が見つかりません"
  exit 1
fi

temp_file=$(mktemp)

# 対象ファイルを一時ファイルにコピー
cp "$target_file" "$temp_file"

# jq で変換ルールを読み込み、各ペアに対して sed で置換処理を実行
jq -r 'to_entries[] | "\(.key)=\(.value)"' "$conversion_file" | while IFS='=' read -r key value; do
  # sed の区切り文字を | に変更し、macOS 用に -i '' を使用
  sed -i '' "s|${key}|${value}|g" "$temp_file"
done

# 一時ファイルを元のファイルに上書き
mv "$temp_file" "$target_file"
echo "置換完了: $target_file"

