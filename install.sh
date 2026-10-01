#!/bin/bash
set -e
PROJECT_DIR="$HOME/Library/Scripts/noTunes-next"
AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.hking.notunes-next.plist"

mkdir -p "$PROJECT_DIR" "$AGENT_DIR"
cp "$(dirname "$0")/block_music.sh" "$PROJECT_DIR/block_music.sh"
chmod +x "$PROJECT_DIR/block_music.sh"
sed "s|__HOME__|$HOME|g" "$(dirname "$0")/$PLIST_NAME" > "$AGENT_DIR/$PLIST_NAME"

launchctl bootout "gui/$(id -u)/com.hking.notunes-next" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$AGENT_DIR/$PLIST_NAME"

echo "noTunes Next installed."
