#!/bin/bash
set -e
pkill -x noTunesNext 2>/dev/null || true
rm -rf "$HOME/Applications/noTunes Next.app"
echo "noTunes Next removed."
