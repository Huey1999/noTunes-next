#!/bin/bash
set -e
launchctl bootout "gui/$(id -u)/com.hking.notunes-next" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.hking.notunes-next.plist"
rm -rf "$HOME/Library/Scripts/noTunes-next"
rm -f /tmp/notunes-next.log /tmp/notunes-next.err
echo "noTunes Next uninstalled."
