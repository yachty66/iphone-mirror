#!/usr/bin/env bash
# Builds the native Mac app ("iPhone Mirror.app") into dist/. With --install it's copied to ~/Applications.
# The app runs mirror.mjs from this checkout, so build it again if you move the repo.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/iPhone Mirror.app"
NODE="$(command -v node)" || { echo "Node 20+ is required."; exit 1; }

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "→ Compiling"
swiftc -O -swift-version 5 -parse-as-library -framework Cocoa -framework WebKit -framework AVFoundation -framework CoreMediaIO \
  "$ROOT"/macos/*.swift -o "$APP/Contents/MacOS/iPhoneMirror"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>iPhone Mirror</string>
  <key>CFBundleDisplayName</key><string>iPhone Mirror</string>
  <key>CFBundleIdentifier</key><string>com.yachty66.iphonemirror</string>
  <key>CFBundleExecutable</key><string>iPhoneMirror</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSCameraUsageDescription</key><string>iPhone Mirror shows your iPhone's screen by capturing it over USB, like QuickTime does.</string>
  <key>NSMicrophoneUsageDescription</key><string>iPhone Mirror plays your iPhone's sound on your Mac.</string>
  <key>NSAppTransportSecurity</key><dict><key>NSAllowsLocalNetworking</key><true/></dict>
  <key>IMRepoPath</key><string>$ROOT</string>
  <key>IMNodePath</key><string>$NODE</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP" >/dev/null
echo "✓ Built $APP"

if [ "${1:-}" = "--install" ]; then
  mkdir -p "$HOME/Applications"
  rm -rf "$HOME/Applications/iPhone Mirror.app"
  cp -R "$APP" "$HOME/Applications/"
  echo "✓ Installed to ~/Applications/iPhone Mirror.app"
fi
