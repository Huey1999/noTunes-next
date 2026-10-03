#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/build.sh"
mkdir -p "$HOME/Applications"
rm -rf "$HOME/Applications/noTunes Next.app"
cp -R "$DIR/build/noTunes Next.app" "$HOME/Applications/"
open "$HOME/Applications/noTunes Next.app"
