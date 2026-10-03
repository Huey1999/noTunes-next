#!/bin/bash
set -e
APP="noTunes Next.app"
rm -rf build
mkdir -p "build/$APP/Contents/MacOS"
swiftc -parse-as-library -framework SwiftUI -framework AppKit Sources/noTunesNextApp.swift -o "build/$APP/Contents/MacOS/noTunesNext"
cp Info.plist "build/$APP/Contents/Info.plist"
echo "Built: build/$APP"
