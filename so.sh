#!/usr/bin/env bash
# screenshot-organizer - Interactive image review and deletion tool
#
# Display images inline in WezTerm/iTerm2-compatible terminals and interactively
# manage them with delete/keep options. Useful for organizing screenshots and
# quickly removing unwanted images without leaving the terminal.
#
# Usage: ./so.sh [directory]
# Example: ./so.sh ~/Downloads

set -euo pipefail

# Display an image inline in the terminal using iTerm2 image protocol
# Converts the image file to base64 and sends it to the terminal for rendering
#
# Arguments:
#   $1 - Path to the image file to display
#   $2 - Display width as percentage (default: 80%)
display_image() {
    local file="$1"
    local width="${2:-auto}"
    
    # Encode image to base64 and send to terminal using iTerm2 protocol
    # WezTerm and many modern terminals support this protocol
    printf '\033]1337;File=inline=1;width=80%%;preserveAspectRatio=1:%s\a' "$(base64 < "$file")"
    echo ""
}

# Display usage information and exit
# Shows the expected command syntax and default behavior
usage() {
    echo "使い方: $0 [ディレクトリ]"
    echo "  ディレクトリ省略時はカレントディレクトリを使用"
    exit 1
}

# Get target directory from command line argument or use current directory
TARGET_DIR="${1:-.}"

# Validate that the target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "エラー: ディレクトリが見つかりません: $TARGET_DIR"
    usage
fi

# Find all image files in the target directory (one level deep)
# Supports: PNG, JPG, JPEG, GIF, WebP formats
# Results are sorted alphabetically and stored in an array
mapfile -t IMAGES < <(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) | sort)

# Exit early if no images were found
if [[ ${#IMAGES[@]} -eq 0 ]]; then
    echo "画像ファイルが見つかりませんでした: $TARGET_DIR"
    exit 0
fi

echo "📁 ${TARGET_DIR} に ${#IMAGES[@]} 件の画像が見つかりました"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Initialize counters for tracking deletion statistics
DELETED=0
KEPT=0
INDEX=0
TOTAL=${#IMAGES[@]}

# Main loop: iterate through each image and prompt user for action
for IMAGE in "${IMAGES[@]}"; do
    INDEX=$((INDEX + 1))
    FILENAME=$(basename "$IMAGE")
    FILESIZE=$(du -sh "$IMAGE" 2>/dev/null | cut -f1)
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[$INDEX/$TOTAL] 📷 $FILENAME ($FILESIZE)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Display the current image inline in the terminal
    display_image "$IMAGE"
    
    echo ""
    echo -n "  [y] 削除  [n] 残す  [q] 終了 > "
    
    # Interactive input loop - read single character and process user action
    while true; do
        # Read a single character without waiting for Enter
        read -r -n 1 KEY
        echo ""
        
        case "$KEY" in
            y|Y)
                # User chose to delete the image
                rm "$IMAGE"
                echo "  🗑️  削除しました: $FILENAME"
                DELETED=$((DELETED + 1))
                break
                ;;
            n|N|"")
                # User chose to keep the image (Enter or 'n')
                echo "  ✅ 残しました: $FILENAME"
                KEPT=$((KEPT + 1))
                break
                ;;
            q|Q)
                # User chose to quit early - show summary and exit
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "📊 結果: 削除 ${DELETED}件 / 残した ${KEPT}件 / 未処理 $((TOTAL - INDEX))件"
                echo "終了しました"
                exit 0
                ;;
            *)
                # Invalid input - prompt again
                echo -n "  y/n/q を入力してください > "
                ;;
        esac
    done
    
    echo ""
done

# All images processed - display final summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ 全て処理完了！"
echo "📊 結果: 削除 ${DELETED}件 / 残した ${KEPT}件"
